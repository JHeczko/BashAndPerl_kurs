#!/bin/bash

# ========== USTAWIENIA ==========
PORT=6789
COUNTER_FILE="$(dirname "$0")/counter.txt"
PID_FILE="$(dirname "$0")/server.pid"
LOGS="$(dirname "$0")/server.log"
HANDLER_SCRIPT="$(dirname "$0")/handler.sh"



parse_args(){
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -p)
        PORT="$2"
        shift 2
        ;;
      *)
        echo "Nieznany argument: $1"
        exit 1
        ;;
    esac
  done
}

clear_ports(){
  # ubic socat'y nasluchujace na porcie sluchajacym
  pkill -f "socat.*TCP-LISTEN:${PORT}" 2>/dev/null || true
}

check_ports(){
  # Sprawdź, czy port wolny
  if lsof -i TCP:"$PORT" -s TCP:LISTEN >/dev/null 2>&1; then
    echo "Port $PORT is unavailable"
    exit 1
  fi
}


cleanup() {

  exit 0
}

load_counter_file(){
  # Wczytaj lub zainicjalizuj licznik
  if [[ -f "$COUNTER_FILE" ]]; then
    COUNTER=$(<"$COUNTER_FILE")
  else
    COUNTER=0
    echo "$COUNTER" > "$COUNTER_FILE"
  fi
}

# ================ MAIN FLOW ==================
# -=-=-=-=-=-=-
parse_args "$@"

# -=-=-=-=-=-=-
check_ports

# -=-=-=-=-=-=-
load_counter_file

# -=-=-=-=-=-=-
# zapisywanie PID'u serwera do pliku
echo $$ > "$PID_FILE"

# -=-=-=-=-=-=-
# oblsugiwanie zakonczenia programu
trap cleanup EXIT SIGTERM SIGINT


# ==================================
# Start serwera
COUNTER_FILE="$COUNTER_FILE" LOGS="$LOGS" socat -v TCP-LISTEN:"$PORT",reuseaddr,fork SYSTEM:"$HANDLER_SCRIPT"