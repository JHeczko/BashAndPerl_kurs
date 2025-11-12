#!/bin/bash
# Jakub Heczko

PORT=6789
COUNTER_FILE="$(dirname "$0")/counter.txt"
PID_FILE="$(dirname "$0")/server.pid"


function cleanup() {
  echo "$COUNTER" > "$COUNTER_FILE"
  rm -f "$PID_FILE"
  exit 0
}


# Odczyt parametrów
while getopts "p:" opt; do
  case "$opt" in
    p) PORT="$OPTARG" 
    ;;

    :) 
        echo "Brak argumentu dla p"
        exit 1
        ;;
    *) ;;
  esac
done

trap cleanup SIGINT SIGTERM

# Sprawdź czy port jest wolny
if lsof -i TCP:"$PORT" -s TCP:LISTEN -Pn >/dev/null 2>&1; then
  echo "Port $PORT is unavailable"
  exit 1
fi

# Wczytaj poprzedni stan licznika (jeśli istnieje)
if [[ -f "$COUNTER_FILE" ]]; then
  COUNTER=$(cat "$COUNTER_FILE")
else
  COUNTER=0
fi

# Zapisz PID
echo $$ > "$PID_FILE"


# Serwer: przyjmuje jedno polecenie, odpowiada lub modyfikuje licznik
while true; do
  # Odbierz dane z socat / netcat
  RESPONSE=$(nc -l -p "$PORT" -q 1)
  case "$RESPONSE" in
    "?")
      echo "$COUNTER" | nc localhost "$PORT" >/dev/null 2>&1 || true
      ;;
    "INC")
      COUNTER=$((COUNTER + 1))
      echo "$COUNTER" > "$COUNTER_FILE"
      ;;
  esac
done
