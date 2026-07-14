#!/usr/bin/env bash
set -euo pipefail

# Let the user draw a region
read -r X Y W H < <(slop -f "%x %y %w %h") || { echo "Selection cancelled."; exit 1; }

# ffmpeg's H.264 encoder needs even dimensions — round down if odd
W=$(( W - (W % 2) ))
H=$(( H - (H % 2) ))

OUTPUT="${1:-recording-$(date +%Y%m%d-%H%M%S).mp4}"

echo "Recording ${W}x${H} at +${X},${Y}  ->  ${OUTPUT}"
echo "Press q to stop."

ffmpeg -f x11grab -framerate 30 -video_size "${W}x${H}" -i ":0.0+${X},${Y}" \
       -c:v libx264 -preset ultrafast -crf 23 -pix_fmt yuv420p \
       "${OUTPUT}"
