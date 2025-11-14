#!/bin/bash

PORT=6789
if [[ -f "$HOME/.config/server.conf" ]]; then
  PORT=$(<"$HOME/.config/server.conf")
fi

send_query() {
  echo "$1" | socat - TCP:localhost:$PORT
}

case "$1" in
  test1)
    send_query "?"
    send_query "INC"
    send_query "INC"
    send_query "?"
    send_query "INC"
    send_query "?"
    ;;
  *)
    if [[ -n "$1" ]]; then
      send_query "$1"
    else
      echo "Użycie: $0 <komenda> lub test1"
    fi
    ;;
esac
