#!/usr/bin/env bash
# extract-kaltura-slides.sh — Extract captions and slide screenshots from Kaltura-hosted videos
#
# Usage:
#   extract-kaltura-slides.sh <partner_id> <entry_id> <ks_token> [output_dir]
#
# Arguments:
#   partner_id  - Kaltura partner ID (e.g., 2935771)
#   entry_id    - Kaltura entry ID (e.g., 1_reex4ldy)
#   ks_token    - Kaltura session token (the long base64 string)
#   output_dir  - Output directory (default: /tmp/kaltura_extract)
#
# Outputs:
#   <output_dir>/metadata.json  - Video metadata (title, duration, etc.)
#   <output_dir>/captions.srt   - Subtitle file (if available)
#   <output_dir>/slides/        - Extracted slide screenshots
#
# Requirements: curl, jq (optional), ffmpeg

set -euo pipefail

PARTNER_ID="${1:?Usage: $0 <partner_id> <entry_id> <ks_token> [output_dir]}"
ENTRY_ID="${2:?Missing entry_id}"
KS_TOKEN="${3:?Missing ks_token}"
OUTPUT_DIR="${4:-/tmp/kaltura_extract}"

KALTURA_API="https://cdnapi-ev.kaltura.com/api_v3"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
REFERER="https://register.nvidia.com/"
SCENE_THRESHOLD="${SCENE_THRESHOLD:-0.3}"

# Ensure ffmpeg is available
FFMPEG="${FFMPEG:-ffmpeg}"
if ! command -v "$FFMPEG" &>/dev/null; then
    if [[ -x /tmp/ffmpeg ]]; then
        FFMPEG=/tmp/ffmpeg
    else
        echo "ERROR: ffmpeg not found. Install it or set FFMPEG=/path/to/ffmpeg" >&2
        exit 1
    fi
fi

mkdir -p "$OUTPUT_DIR/slides"

echo "==> Fetching video metadata..."
curl -s "${KALTURA_API}/service/baseentry/action/get?entryId=${ENTRY_ID}&format=1&ks=${KS_TOKEN}" \
    -o "$OUTPUT_DIR/metadata.json"

# Extract basic info
if command -v jq &>/dev/null; then
    TITLE=$(jq -r '.name // "Unknown"' "$OUTPUT_DIR/metadata.json")
    DURATION=$(jq -r '.duration // 0' "$OUTPUT_DIR/metadata.json")
    echo "    Title: $TITLE"
    echo "    Duration: $((DURATION / 60))m $((DURATION % 60))s"
else
    echo "    (install jq for pretty metadata output)"
fi

echo "==> Checking for captions..."
CAPTION_RESPONSE=$(curl -s "${KALTURA_API}/service/caption_captionasset/action/list?filter[entryIdEqual]=${ENTRY_ID}&format=1&ks=${KS_TOKEN}")

# Parse caption assets
CAPTION_IDS=()
CAPTION_LANGS=()
if command -v jq &>/dev/null; then
    TOTAL=$(echo "$CAPTION_RESPONSE" | jq -r '.totalCount // 0')
    if [[ "$TOTAL" -gt 0 ]]; then
        while IFS=$'\t' read -r cid clang clabel; do
            CAPTION_IDS+=("$cid")
            CAPTION_LANGS+=("$clabel ($clang)")
        done < <(echo "$CAPTION_RESPONSE" | jq -r '.objects[]? | [.id, .languageCode, .label] | @tsv')
    fi
else
    # Fallback: grep for IDs
    if echo "$CAPTION_RESPONSE" | grep -q '"id"'; then
        CID=$(echo "$CAPTION_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        if [[ -n "$CID" ]]; then
            CAPTION_IDS+=("$CID")
            CAPTION_LANGS+=("unknown")
        fi
    fi
fi

if [[ ${#CAPTION_IDS[@]} -gt 0 ]]; then
    echo "    Found ${#CAPTION_IDS[@]} caption track(s):"
    for i in "${!CAPTION_IDS[@]}"; do
        echo "      - ${CAPTION_LANGS[$i]}: ${CAPTION_IDS[$i]}"
    done

    # Download all caption tracks
    for i in "${!CAPTION_IDS[@]}"; do
        CID="${CAPTION_IDS[$i]}"
        LANG="${CAPTION_LANGS[$i]}"
        SAFE_LANG=$(echo "$LANG" | tr ' ()' '_' | tr -cd 'a-zA-Z0-9_-')
        OUT_FILE="$OUTPUT_DIR/captions_${SAFE_LANG}.srt"

        echo "    Downloading captions: $LANG..."
        curl -s -L \
            -H "User-Agent: $UA" \
            -H "Referer: $REFERER" \
            -H "Origin: ${REFERER%/}" \
            -o "$OUT_FILE" \
            "${KALTURA_API}/service/caption_captionasset/action/serve?captionAssetId=${CID}&ks=${KS_TOKEN}"

        SIZE=$(wc -c < "$OUT_FILE" | tr -d ' ')
        if [[ "$SIZE" -eq 0 ]]; then
            echo "    WARNING: Caption download returned empty (access control restriction)"
            rm -f "$OUT_FILE"
        else
            echo "    Saved: $OUT_FILE ($SIZE bytes)"
            # Also copy as the default captions.srt
            cp "$OUT_FILE" "$OUTPUT_DIR/captions.srt"
        fi
    done
else
    echo "    No captions found."
fi

echo "==> Fetching HLS manifest..."
MANIFEST_URL="https://cdnapi-ev.kaltura.com/p/${PARTNER_ID}/sp/${PARTNER_ID}00/playManifest/entryId/${ENTRY_ID}/protocol/https/format/applehttp/ks/${KS_TOKEN}/a.m3u8"

echo "==> Extracting slides via scene-change detection (threshold=${SCENE_THRESHOLD})..."
"$FFMPEG" -hide_banner -loglevel warning -stats \
    -headers "User-Agent: ${UA}
Referer: ${REFERER}
Origin: ${REFERER%/}
" \
    -i "$MANIFEST_URL" \
    -vf "select='gt(scene,${SCENE_THRESHOLD})',scale=1920:-1" \
    -vsync vfr -q:v 2 \
    "$OUTPUT_DIR/slides/slide_%04d.jpg" 2>&1

SLIDE_COUNT=$(ls "$OUTPUT_DIR/slides/"*.jpg 2>/dev/null | wc -l | tr -d ' ')
echo "==> Done! Extracted $SLIDE_COUNT slides."
echo "    Output directory: $OUTPUT_DIR"
echo "    Slides: $OUTPUT_DIR/slides/"
[[ -f "$OUTPUT_DIR/captions.srt" ]] && echo "    Captions: $OUTPUT_DIR/captions.srt"
echo "    Metadata: $OUTPUT_DIR/metadata.json"
