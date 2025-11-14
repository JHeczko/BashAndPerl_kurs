#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_PATH="$SCRIPT_DIR/server.sh"
PID_FILE="$SCRIPT_DIR/server.pid"
PID_LISTENER_FILE="$SCRIPT_DIR/listener.pid"
CONFIG_FILE="$HOME/.config/server.conf"

get_pid() {
  [[ -f "$PID_FILE" ]] && cat "$PID_FILE"
}

is_running() {
  local pid
  pid=$(get_pid)
  [[ -n "$pid" && -d "/proc/$pid" ]]
}

check_port(){
  # Sprawdź czy port jest wolny
  if lsof -iTCP:"$1" -sTCP:LISTEN -Pn >/dev/null 2>&1; then
    echo "Port $1 is unavailable"
    exit 1
  fi
}

start_server() {
  local port=$1

  # Priorytet: argument -> config -> domyślny
  if [[ -z "$port" && -f "$CONFIG_FILE" ]]; then
    port=$(cat "$CONFIG_FILE")
  fi
  [[ -z "$port" ]] && port=6789

  check_port "$port"

  # Sprawdź czy już działa
  if is_running; then
    echo "Dalej chodzi serwer... Wychodze"
    exit 0
  fi

  # Uruchom w nowej sesji, zapisz pid procesu sesji (setsid zwraca PID child)
  # używamy setsid żeby móc killować grupę później
  nohup setsid bash "$SERVER_PATH" -p "$port" >/dev/null 2>&1 &
  local pid=$!
  echo "$pid" > "$PID_FILE"
}

clear_ports(){
  # fallback: ubić socat'y nasłuchujące na porcie z pliku config lub domyślnie 6789
  local port=6789
  [[ -f "$CONFIG_FILE" ]] && port=$(<"$CONFIG_FILE")
  pkill -f "socat.*TCP-LISTEN:${port}" 2>/dev/null || true
}

stop_server() {
  local pid
  pid=$(get_pid)

  if [[ -n "$pid" ]]; then
    # spróbuj zabić całą grupę procesów należącą do tego pids (używamy -TERM na negative PID)
    kill -TERM -"${pid}" 2>/dev/null || true
    sleep 0.5
    kill -KILL -"${pid}" 2>/dev/null || true
    rm -f "$PID_FILE"
  fi

  # fallback: ubić socat'y nasłuchujące na porcie z pliku config lub domyślnie 6789
  clear_ports
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
  clear)
    clear_ports
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status} [port]"
    ;;
esac
