# Save Meta Content

Summarize a Meta Workplace post, internal wiki, or doc and save to MetaVault Learnings.

**Usage**: `/save-meta <URL> [URL2] [URL3] ...`

Accepts one or more URLs separated by spaces or newlines. Process each URL independently — load, summarize, and save each one as its own note.

Supported URLs:
- Workplace posts (`fb.workplace.com/groups/...`)
- Workplace videos (`fb.workplace.com/.../videos/...`)
- Wiki pages (`internalfb.com/wiki/...`)
- Static docs (`internalfb.com/intern/staticdocs/...`)
- Tasks (`internalfb.com/T...`)
- Pastes (`internalfb.com/phabricator/paste/view/P...`)

## Workflow

### 1. Load Content
- **Workplace videos**: Use the `workplace-video-subtitles` skill to extract subtitles, then summarize the transcript.
- **Everything else**: Use the `knowledge_load` MCP tool to fetch the URL content.

### 2. Summarize
Provide a structured summary:
- **Title**: Title of the post/wiki/doc
- **TL;DR**: 1-2 sentence summary
- **Key Points**: Bulleted list of main takeaways
- **Details**: Longer summary organized by section/topic

### 3. Save to Vault
Save to `~/my-vault/Learnings/<Title>.md` with frontmatter:
```yaml
---
created: {{today's date as YYYY-MM-DD}}
type: learning
tags: [meta, <format-tag>, <topic-tags>]
source: <URL>
---
```
- Always include `meta` tag.
- Add a format tag: `video-summary`, `wiki-notes`, `post-notes`, `doc-notes`, etc.
- Add topic tags inferred from content (e.g. `infrastructure`, `claude-code`, `oncall`, `best-practices`).

### 4. Confirm
Show the file path and a brief summary of what was saved.
