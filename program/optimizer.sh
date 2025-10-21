#!/bin/bash
# Jakub Heczko

HARDLINKS_FLAG=1
MAX_DEPTH=0
HASH_ALGO="md5sum"


function check_for_help_apperance(){
  for arg in "$@"; do
    if [[ $arg == "--help" ]]; then
      printf %s $'Pomoc dla programu:\n\t- --replace-with-hardlinks: Zastępuje nadmiarowe kopie pliku hardlinkami.\n\t- --max-depth=N: Opcjonalny parametr pozwalający ustawić maksymalną głębokość rekurencyjnego skanowania katalogów.\n\t- --hash-algo=ALGO: Pozwala wybrać algorytm haszowania do porównania plików, np. md5sum (domyślny), sha1sum, sha256sum. Jeśli polecenie XXX nie istnieje wówczas drukujemy "XXX not supported". i zakańczamy pracę programu.\n\t- --help: jeśli opcja obecna, opis użycia programu **niezależnie od obecności innych opcji i zakończenie pracy programu**\n'
      exit 0
    fi
  done
}

function parse_args(){
ARGS=$(getopt -o "" -l "replace-with-hardlinks,max-depth:,hash-algo:,help" -- "$@")
if [[ $? -ne 0 ]]; then
  echo "[ERROR] Failed to parse arguments"
  exit 1
fi

eval set -- "$ARGS"

while true; do
  case "$1" in

    --replace-with-hardlinks)

      HARDLINKS_FLAG=0
      shift
      ;;


    --max-depth)
      if [[ -z "$2" || "$2" == -* ]]; then
        echo "[ERROR] --max-depth option require a posotive number of the recursion depth"
        exit 1
      fi

      if [[ ! "$2" =~ [0-9]+ ]]; then
        echo "[ERROR] Opcja musi byc integerem"
        exit 1
      fi

      MAX_DEPTH=$2
      shift 2
      ;;


    --hash-algo)
     if [[ -z "$2" || "$2" == -* ]]; then
        echo "[ERROR] --hash-algo option require a name of algorithm"
        exit 1
      fi

      if [[ "$2" != "md5sum" && "$2" != "sha1sum" && "$2" != "sha256sum" ]]; then
        echo "[ERROR] No such hashing algorythm supported, please choose only from the following list: md5sum ,sha1sum ,sha256sum"
        exit 1
      fi

      HASH_ALGO="$2"
      shift 2
      ;;


    --)
      shift
      break
      ;;


    *)
      echo "[ERROR] Nieznana opcja: $1"
      exit 1
      ;;

  esac
done
}

function hash(){
  local text=$1
  echo -n "$text" | $HASH_ALGO | awk '{print $1}'
}

function indepth_search(){
  files=$@
  files_depth_down=""

  for file in $files; do
    if [[ $file == '.' || $file == '..' ]]; then
      continue
    fi

    if [[ -d file ]]

    echo $(len file)
  done
}

# =================================================

check_for_help_apperance "$@"

parse_args "$@"

indepth_search $(ls -a)