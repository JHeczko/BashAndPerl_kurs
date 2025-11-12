#!/bin/bash
# Jakub Heczko


HOST="localhost"
PORT=6789

CONFIG_FILE="$HOME/.config/server.conf"
[[ -f "$CONFIG_FILE" ]] && PORT=$(cat "$CONFIG_FILE")

if [[ -n "$2" ]]; then
  PORT="$2"
fi

send() {
  echo "$1" | nc "$HOST" "$PORT"
}

case "$1" in
  test1)
    send "?"
    send "INC" >/dev/null
    send "INC" >/dev/null
    send "?"
    send "INC" >/dev/null
    send "?"
    ;;
  *)
    echo "Usage: $0 test1 [port]"
    ;;
esac
