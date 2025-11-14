#!/bin/bash

# ========== USTAWIENIA ==========
PORT=6789
COUNTER_FILE="$(dirname "$0")/counter.txt"
PID_FILE="$(dirname "$0")/server.pid"
LOGS="$(dirname "$0")/server.out"
HANDLER_SCRIPT="$(dirname "$0")/.handler.sh"

# ==================================
# Odczytaj argumenty
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

# ==================================
# Wczytaj lub zainicjalizuj licznik
if [[ -f "$COUNTER_FILE" ]]; then
  COUNTER=$(<"$COUNTER_FILE")
else
  COUNTER=0
fi

save_counter() {
  echo "$COUNTER" > "$COUNTER_FILE"
}

trap save_counter EXIT

# ==================================
# Sprawdź, czy port wolny
if lsof -i :"$PORT" >/dev/null 2>&1; then
  echo "Port $PORT is unavailable"
  exit 1
fi

echo "[SERVER] Listening on port $PORT..."
echo $$ > "$PID_FILE"

# ==================================
# Stwórz tymczasowy skrypt obsługi
cat > "$HANDLER_SCRIPT" << 'HANDLER_EOF'
#!/bin/bash
read msg

echo "[$(date)] $msg" >> "$LOGS"

case "$msg" in
  "?")
    if [[ -f "$COUNTER_FILE" ]]; then
      cat "$COUNTER_FILE"
    else
      echo "0"
    fi
    ;;
  "INC")
    if [[ -f "$COUNTER_FILE" ]]; then
      COUNTER=$(<"$COUNTER_FILE")
    else
      COUNTER=0
    fi
    ((COUNTER++))
    echo "$COUNTER" > "$COUNTER_FILE"
    ;;
  *)
    echo "Unknown command"
    ;;
esac
HANDLER_EOF

chmod +x "$HANDLER_SCRIPT"

# Posprzątaj po zakończeniu
trap "rm -f '$HANDLER_SCRIPT'; save_counter" EXIT

# ==================================
# Start serwera
COUNTER_FILE="$COUNTER_FILE" LOGS="$LOGS" socat -v TCP-LISTEN:"$PORT",reuseaddr,fork SYSTEM:"$HANDLER_SCRIPT"