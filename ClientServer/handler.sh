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