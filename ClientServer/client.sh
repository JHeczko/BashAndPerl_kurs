#!/bin/bash

PORT=6789
if [[ -f "$HOME/.config/server.conf" ]]; then
  PORT=$(<"$HOME/.config/server.conf")
fi

send_query() {
  echo "$1" | socat - TCP:localhost:$PORT
}


parse_args(){
  ARGS=$(getopt -o p: -l test1 -- "$@")

  eval set -- "$ARGS"

  while true; do
    case "$1" in
      --test1)
        send_query "?"
        send_query "INC"
        send_query "INC"
        send_query "?"
        send_query "INC"  
        send_query "?"
        echo "$1"
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
        echo $1 $2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      *)
        # if [[ -n "$1" ]]; then
        #   send_query "$1"
        # else
        #   echo "Uzycie: $0 <komenda> lub test1"
        # fi
        echo "Bad args"
        exit 1
        #shift 1
        ;;
    esac
  done
}

parse_args "$@"
