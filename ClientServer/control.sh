#!/bin/bash
# Jakub Heczko


PID_FILE="$(dirname "$0")/server.pid"
CONFIG_FILE="$HOME/.config/server.conf"
SERVER_PATH="$(dirname "$0")/server.sh"

function get_pid() {
  local pid

  if [[ -f "$PID_FILE" ]]; then 
    pid=$(cat "$PID_FILE")
    echo "$pid"
  fi
}

function is_running() {
  local pid
  pid=$(get_pid)
  if [[ -n "$pid" && -d "/proc/$pid" ]]; then
    return 0  #pamietamy 0 to prawda, 1 to falsz
  else
    return 1
  fi
}

function start_server() {
  local port=$1

  # Jesli port niepodany to wtedy patrzymy czy config jest
  if [[ -z "$port" && -f "$CONFIG_FILE" ]]; then
    port=$(cat "$CONFIG_FILE")
  fi
  
  # Jezeli dalej jest 0 to wtedy bierzemy standardowy port
  if [[ -z "$port" ]]; then 
      port=6789
  fi


  # Sprawdź czy już działa
  if is_running; then
    exit 0
  fi

  # Uruchom w tle
  nohup bash "$SERVER_PATH" -p "$port" >/dev/null 2>/dev/null &
}

function stop_server() {
  if is_running; then
    kill "$(get_pid)" >/dev/null 2>&1
    rm -f "$PID_FILE"
  fi
}

case "$1" in
    start)
        start_server "$2"
        ;;
    stop)
        stop_server
        ;;
    restart)
        stop_server
        sleep 1
        start_server "$2"
        ;;
    status)
        get_pid
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status} [port]"
        ;;
esac