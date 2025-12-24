mkcd() {
  mkdir -p "$1" && cd "$1"
}

u() {
  local args
  args="${@:-pi}"
  unison "$args"
}
