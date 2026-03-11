# Video Summary

Summarize a video from YouTube, Bilibili, or Workplace by extracting subtitles and generating a summary.

**Usage**: `/video-summary <URL>`

## Workflow

### 1. Detect Platform
- **Workplace** (`fb.workplace.com`): Use the `workplace-video-subtitles` skill to extract subtitles. Save to **MetaVault**.
- **YouTube** (`youtube.com`, `youtu.be`): Proceed with yt-dlp. Save to **personal vault**.
- **Bilibili** (`bilibili.com`, `b23.tv`): Proceed with yt-dlp. Save to **personal vault**.

### 2. Download Subtitles
Run in a temp directory:
```bash
cd /tmp
yt-dlp --write-auto-sub --write-sub --sub-lang "en,zh-Hans,zh" --skip-download --no-overwrites -o "video_sub" "<URL>" 2>&1
```

If no subtitles are found, try listing available subs:
```bash
yt-dlp --list-subs "<URL>" 2>&1
```
Then retry with an available language.

### 3. Read Subtitle File
Read the downloaded `.vtt` or `.srt` file from `/tmp/video_sub*`.

### 4. Summarize
Provide a structured summary:
- **Title**: Video title (from yt-dlp output or subtitle content)
- **TL;DR**: 1-2 sentence summary
- **Key Points**: Bulleted list of main takeaways
- **Details**: Longer summary organized by topic/timestamp if available

### 5. Save
Save the summary based on platform:

**Workplace videos** → MetaVault Learnings:
- Location: `~/my-vault/Learnings/<Video Title>.md`
- Frontmatter:
  ```yaml
  ---
  created: {{today's date as YYYY-MM-DD}}
  type: learning
  tags: [meta, video-summary, <topic-tags>]
  source: <URL>
  ---
  ```
- Always include `meta` and `video-summary` tags, plus topic tags inferred from content (e.g. `infrastructure`, `ai`, `best-practices`).

**YouTube / Bilibili videos** → Personal vault Sources:
- Location: `~/my-personal-vault/sources/<Video Title>.md`
- Frontmatter:
  ```yaml
  ---
  created: {{today's date as YYYY-MM-DD}}
  type: source
  tags: [video-summary, <topic-tags>]
  source: <URL>
  ---
  ```
- Always include `video-summary` tag, plus topic tags inferred from content (e.g. `programming`, `math`, `tech`).

### 6. Cleanup
```bash
rm -f /tmp/video_sub*
```
