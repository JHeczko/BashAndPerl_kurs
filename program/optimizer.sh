#!/bin/bash
# Jakub Heczko

HARDLINKS_FLAG=1
INTERACTIVE_FLAG=1
MAX_DEPTH=0
HASH_ALGO="md5sum"
DIRNAME="./"

# Statistics
NUMBER_OF_PROCCESSED_FILES=0
NUMBER_OF_FOUND_DUPLICATES=0
NUMBER_OF_REPLACED_DUPLICATES=0

declare -A size_map
declare -A hash_map

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

DIRNAME=$1
}

function hash(){
  local dir=$1
  local text=$(cat "$dir")
  echo -n "$text" | $HASH_ALGO | awk '{print $1}'
}

function split() {
  local value="$1"
  local separator="#####"
  IFS="$separator" read -r -a result <<< "$value"
  printf '%s\n' "${result[@]}"
}

function size(){
  local file=$1
  echo $(stat -c%s "$1")
}

function indepth_search(){
  local working_directory="${1%/}"
  local depth=$2
  local files=$(ls -a "$1")

  for file in $files; do
    if [[ $depth -gt $MAX_DEPTH ]]; then
      return
    fi

    if [[ $file == '.' || $file == '..' ]]; then
      continue
    fi

    if [[ -d $file ]]; then
      indepth_search "$working_directory/$file" "$((depth+1))"
    else
      #echo "$working_directory/$file $(size "$working_directory/$file")"
      size_map[$(size "$working_directory/$file")]+="#####$working_directory/$file#####"
    fi
  done
}

function hash_search(){
  for key in "${!size_map[@]}"; do
    local files_raw=${size_map[$key]}
    local files_arr=$(split $files_raw)
    for file in $files_arr; do
        file_hash="$(hash $file)"
        hash_map[$file_hash]+="#####$file#####"
    done
  done
}

# =================================================


check_for_help_apperance "$@"

parse_args "$@"

if [[ ! -d $DIRNAME ]]; then
  echo "Given file is not directory"
  exit 1
fi

indepth_search "$DIRNAME" 0

hash_search

for key in "${!hash_map[@]}"; do
    value="${hash_map[$key]}"
    echo "Klucz: $key -> Wartość: $value"
done