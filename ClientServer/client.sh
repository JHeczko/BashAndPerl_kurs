#!/bin/bash

PORT=6789
if [[ -f "$HOME/.config/server.conf" ]]; then
  PORT=$(<"$HOME/.config/server.conf")
fi

send_query() {
  echo "$1" | socat - TCP:localhost:$PORT
}

test_1(){
  send_query "?"
  send_query "INC"
  send_query "INC"
  send_query "?"
  send_query "INC"  
  send_query "?"
}

parse_args(){
  ARGS=$(getopt -o p: -l test1 -- "$@")

  eval set -- "$ARGS"

  while true; do
    case "$1" in
      --test1)
        test_1
        shift 1
        ;;
      -p)
        if [[ $2 =~ [0-9]+ && $2 -gt 0 && $2 -le 65535 ]]; then
          PORT="$PORT"
        else
          echo "Port should be integer beetwen 0 and 65535"
          exit 1
        fi
        PORT=$2
        shift 2
        ;;
      --)
        shift 1
        break
        ;;
      *)
        echo "Bad arg: " "$1"
        exit 1
        ;;
    esac
  done

  while [[ $# -ne 0 ]]; do
    case "$1" in
      test1)
        test_1
        shift 1
        ;;
    esac
  done
}

parse_args "$@"
