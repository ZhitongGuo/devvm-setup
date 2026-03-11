# Save to Personal Vault

Read any content source, generate notes, and save to the Moonquakes personal vault.

**Usage**: `/save <URL or file path> [URL2] [URL3] ...`

Accepts one or more URLs/paths separated by spaces or newlines. Process each source independently — detect type, summarize, and save each one as its own note.

## Supported Sources

| Type | Examples |
|------|----------|
| Video | YouTube, Bilibili, Vimeo URLs |
| Podcast | Spotify, Apple Podcasts URLs, local audio files (.mp3, .m4a) |
| Blog | Any web URL (Medium, Substack, personal blogs, etc.) |
| GitHub | Repos, READMEs, issues, discussions |
| Course | Coursera, Udemy, edX, or any course page URL |
| Book | Local files (.epub, .txt), Goodreads/Amazon links for metadata |
| PDF | Local `.pdf` files or PDF URLs |

## Workflow

### 1. Detect Source Type

**Video** (youtube.com, youtu.be, bilibili.com, b23.tv, vimeo.com):
```bash
yt-dlp --write-auto-sub --write-sub --sub-lang "en,zh-Hans,zh,ja" --skip-download --no-overwrites -o "/tmp/save_sub" "<URL>" 2>&1
```
Read the downloaded subtitle file. If no subs found, list available subs and retry.

**Podcast / Audio** (spotify, apple podcasts, local .mp3/.m4a):
- For URLs: try `yt-dlp` to extract subtitles or description.
- For local audio: inform user that audio transcription is not supported in CLI — suggest uploading to a transcription service first, then saving the transcript.

**PDF** (local `.pdf` files or URLs ending in `.pdf`):
- Local: Read the file directly with the Read tool.
- URL: Use WebFetch to download and read.

**GitHub** (github.com):
- Repos: Use `gh` CLI or WebFetch to read README and key files.
- Issues/PRs/Discussions: Use `gh` CLI to fetch content.

**Blog / Web page** (any other URL):
- Use WebFetch to read the page content.

**Book** (local .epub, .txt):
- Read the file directly.

### 2. Generate Notes

Produce a structured summary:
- **Title**: Source title
- **TL;DR**: 1-2 sentence summary
- **Key Points**: Bulleted main takeaways
- **Detailed Notes**: Organized by section/topic/timestamp as appropriate
- **Quotes / Highlights**: Notable excerpts (if applicable)
- **References**: Links to related resources mentioned in the content

### 3. Auto-Tag

Infer relevant tags from content. Examples:
- Topics: `programming`, `math`, `ai`, `systems`, `design`, `finance`, `philosophy`
- Format: `video-summary`, `podcast-notes`, `blog-notes`, `book-notes`, `course-notes`, `paper-notes`, `github`
- Language: `english`, `chinese`, `japanese` (if non-English)

### 4. Save

Save to `~/my-personal-vault/sources/<Title>.md` with frontmatter:
```yaml
---
created: {{today's date as YYYY-MM-DD}}
type: source
tags: [<format-tag>, <topic-tags>]
source: <URL or file path>
---
```

### 5. Cleanup
```bash
rm -f /tmp/save_sub*
```

### 6. Git Push
Commit all changes in `~/my-personal-vault` and push:
```bash
cd ~/my-personal-vault && git add -A && git commit -m "Add/update sources" && git push
```

### 7. Confirm
Show the saved file path and a brief summary.
