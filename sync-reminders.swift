#!/usr/bin/env swift
//
// sync-reminders.swift
// Two-way sync between Apple Reminders and an Obsidian vault markdown file.
//
// Usage: swift sync-reminders.swift [--vault-path <path>] [--dry-run]
//
// - Reads open reminders from Apple Reminders for configured lists
// - Reads Reminders.md from the vault, detects completions and new items
// - Syncs completions back to Apple Reminders
// - Creates new items added in Obsidian in Apple Reminders
// - Regenerates Reminders.md with current state
//

import EventKit
import Foundation

// MARK: - Configuration

let syncedLists = ["Exploitation", "Healing", "Exploration", "Fun", "Groceries"]

let defaultVaultPath = NSString(
    string: "~/Library/CloudStorage/GoogleDrive-topayton401@gmail.com/My Drive/vaults/Moonquakes"
).expandingTildeInPath

// MARK: - Argument parsing

var vaultPath = defaultVaultPath
var dryRun = false

var args = CommandLine.arguments.dropFirst()
while let arg = args.first {
    args = args.dropFirst()
    switch arg {
    case "--vault-path":
        if let val = args.first {
            vaultPath = NSString(string: val).expandingTildeInPath
            args = args.dropFirst()
        }
    case "--dry-run":
        dryRun = true
    default:
        break
    }
}

let mdPath = "\(vaultPath)/notes/Reminders.md"

// MARK: - Types

struct MdItem: Hashable {
    let list: String
    let title: String
    let completed: Bool
    let due: String?       // "2026-03-11" format or nil
    let notes: String?

    /// Normalized key for matching between Reminders and Obsidian.
    /// Strips punctuation/whitespace differences so hand-edited titles still match.
    var key: String {
        let normalized = title
            .trimmingCharacters(in: .whitespaces)
            // Normalize full-width parens/commas to ASCII
            .replacingOccurrences(of: "（", with: "(")
            .replacingOccurrences(of: "）", with: ")")
            .replacingOccurrences(of: "，", with: ",")
            .replacingOccurrences(of: "、", with: ",")
            // Normalize dashes
            .replacingOccurrences(of: " — ", with: " ")
            .replacingOccurrences(of: " - ", with: " ")
            // Collapse whitespace
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            // Strip trailing punctuation
            .trimmingCharacters(in: CharacterSet.punctuationCharacters.union(.whitespaces))
            .lowercased()
        return "\(list.lowercased())|\(normalized)"
    }
}

// MARK: - Parse existing Reminders.md

func parseMd(at path: String) -> [MdItem] {
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return []
    }

    var items: [MdItem] = []
    var currentList: String? = nil

    for line in content.components(separatedBy: "\n") {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Detect list headings: ## Exploitation, ## Healing, etc.
        if trimmed.hasPrefix("## ") {
            let heading = String(trimmed.dropFirst(3))
            if syncedLists.contains(heading) {
                currentList = heading
            } else {
                currentList = nil
            }
            continue
        }

        guard let list = currentList else { continue }

        // Parse checkbox items: - [ ] or - [x]
        if trimmed.hasPrefix("- [") {
            let completed: Bool
            let rest: String

            if trimmed.hasPrefix("- [x] ") || trimmed.hasPrefix("- [X] ") {
                completed = true
                rest = String(trimmed.dropFirst(6))
            } else if trimmed.hasPrefix("- [ ] ") {
                completed = false
                rest = String(trimmed.dropFirst(6))
            } else {
                continue
            }

            // Extract due date if present: `due: 2026-03-11`
            var title = rest
            var due: String? = nil
            if let dueRange = rest.range(of: "`due: ") {
                let afterDue = rest[dueRange.upperBound...]
                if let endTick = afterDue.firstIndex(of: "`") {
                    due = String(afterDue[..<endTick])
                    // Remove the due portion from title
                    let fullDueStr = String(rest[dueRange.lowerBound...endTick])
                    title = rest.replacingOccurrences(of: fullDueStr, with: "")
                        .trimmingCharacters(in: .whitespaces)
                }
            }

            // Clean up title: remove trailing " —" artifacts
            title = title
                .replacingOccurrences(of: " —$", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespaces)

            items.append(MdItem(list: list, title: title, completed: completed, due: due, notes: nil))
        }
    }

    return items
}

// MARK: - Fetch reminders from Apple Reminders

func fetchReminders(store: EKEventStore) -> [EKReminder] {
    let calendars = store.calendars(for: .reminder)
        .filter { syncedLists.contains($0.title) }
    let predicate = store.predicateForReminders(in: calendars)

    var results: [EKReminder] = []
    let semaphore = DispatchSemaphore(value: 0)
    store.fetchReminders(matching: predicate) { reminders in
        results = reminders ?? []
        semaphore.signal()
    }
    semaphore.wait()
    return results
}

/// Convert EKReminder to our MdItem for comparison
func reminderToMdItem(_ r: EKReminder) -> MdItem {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    var due: String? = nil
    if let dc = r.dueDateComponents, let d = Calendar.current.date(from: dc) {
        due = df.string(from: d)
    }
    let notes = r.notes?.replacingOccurrences(of: "\n", with: " ")
    // Flatten multiline titles (e.g. "SOY ISOFLAVONE\nCONCENTRATE")
    let title = (r.title ?? "(untitled)")
        .replacingOccurrences(of: "\n", with: " ")
        .trimmingCharacters(in: .whitespaces)
    return MdItem(
        list: r.calendar.title,
        title: title,
        completed: r.isCompleted,
        due: due,
        notes: notes
    )
}

// MARK: - Generate markdown

func generateMd(items: [MdItem]) -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    let today = df.string(from: Date())

    var out = """
    ---
    tags:
      - reminders
      - sync
    synced: \(today)
    source: apple-reminders
    ---

    # Reminders

    > Synced from Apple Reminders by Kael. Last sync: \(today).

    """

    // Remove leading indentation from heredoc
    out = out.components(separatedBy: "\n")
        .map { $0.hasPrefix("    ") ? String($0.dropFirst(4)) : $0 }
        .joined(separator: "\n")

    for list in syncedLists {
        let listItems = items.filter { $0.list == list && !$0.completed }
        // Only include section if there are open items
        guard !listItems.isEmpty else { continue }

        out += "\n## \(list)\n\n"
        for item in listItems {
            var line = "- [ ] \(item.title)"
            if let due = item.due {
                line += " `due: \(due)`"
            }
            out += line + "\n"
        }
    }

    return out
}

// MARK: - Main sync logic

func main() {
    let store = EKEventStore()
    let semaphore = DispatchSemaphore(value: 0)
    var accessGranted = false

    store.requestFullAccessToReminders { granted, error in
        accessGranted = granted
        if let error = error {
            print("ERROR: \(error.localizedDescription)")
        }
        semaphore.signal()
    }
    semaphore.wait()

    guard accessGranted else {
        print("ERROR: Reminders access denied.")
        exit(1)
    }

    // 1. Parse existing Obsidian file
    let mdItems = parseMd(at: mdPath)
    // 2. Fetch current Apple Reminders
    let ekReminders = fetchReminders(store: store)
    let ekItems = ekReminders.map { reminderToMdItem($0) }
    let ekByKey = Dictionary(
        zip(ekReminders, ekItems).map { ($1.key, $0) },
        uniquingKeysWith: { first, _ in first }
    )
    let ekItemByKey = Dictionary(ekItems.map { ($0.key, $0) }, uniquingKeysWith: { first, _ in first })

    var completedCount = 0
    var createdCount = 0

    // 3. Sync completions: items checked off in Obsidian → mark complete in Apple Reminders
    for mdItem in mdItems where mdItem.completed {
        if let ekReminder = ekByKey[mdItem.key], !ekReminder.isCompleted {
            if dryRun {
                print("DRY RUN: Would complete '\(mdItem.title)' in list '\(mdItem.list)'")
            } else {
                ekReminder.isCompleted = true
                ekReminder.completionDate = Date()
                do {
                    try store.save(ekReminder, commit: true)
                    print("COMPLETED: '\(mdItem.title)' in '\(mdItem.list)'")
                    completedCount += 1
                } catch {
                    print("ERROR completing '\(mdItem.title)': \(error)")
                }
            }
        }
    }

    // 4. Sync new items: items in Obsidian that don't exist in Apple Reminders → create them
    let calendars = store.calendars(for: .reminder)
    let calByName = Dictionary(calendars.map { ($0.title, $0) }, uniquingKeysWith: { first, _ in first })

    for mdItem in mdItems where !mdItem.completed {
        if ekItemByKey[mdItem.key] == nil {
            // New item from Obsidian
            guard let calendar = calByName[mdItem.list] else {
                print("WARNING: List '\(mdItem.list)' not found in Reminders, skipping '\(mdItem.title)'")
                continue
            }

            if dryRun {
                print("DRY RUN: Would create '\(mdItem.title)' in list '\(mdItem.list)'")
            } else {
                let reminder = EKReminder(eventStore: store)
                reminder.title = mdItem.title
                reminder.calendar = calendar

                // Set due date if present
                if let dueStr = mdItem.due {
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd"
                    if let date = df.date(from: dueStr) {
                        reminder.dueDateComponents = Calendar.current.dateComponents(
                            [.year, .month, .day], from: date
                        )
                    }
                }

                do {
                    try store.save(reminder, commit: true)
                    print("CREATED: '\(mdItem.title)' in '\(mdItem.list)'")
                    createdCount += 1
                } catch {
                    print("ERROR creating '\(mdItem.title)': \(error)")
                }
            }
        }
    }

    // 5. Build final state: merge Apple Reminders (source of truth) with any new Obsidian items
    //    Re-fetch after modifications
    let finalReminders = fetchReminders(store: store)
    let finalItems = finalReminders.map { reminderToMdItem($0) }

    // 6. Write updated markdown
    let markdown = generateMd(items: finalItems)

    if dryRun {
        print("\n--- Generated markdown (dry run) ---")
        print(markdown)
    } else {
        do {
            try markdown.write(toFile: mdPath, atomically: true, encoding: .utf8)
            print("\nSYNC COMPLETE: \(completedCount) completed, \(createdCount) created")
            print("Updated: \(mdPath)")
        } catch {
            print("ERROR writing markdown: \(error)")
        }
    }
}

main()
