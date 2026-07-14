mkcd() {
  mkdir -p "$1" && cd "$1"
}


duds() {
  "du -hd 1 "$@" | sort -h"      # Disk usage, depth 1, sorted
}
