#!/bin/bash
# Jakub Heczko

# check_for_help_apperance()
# checkes if argument -help is in the params
#
# Input Arguments:
# - all program input parameters
function check_for_help_apperance(){
  for arg in "$@"; do
    if [[ $arg == "--help" ]]; then
      printf %s $'Pomoc dla programu:\n\t- --replace-with-hardlinks: Zastępuje nadmiarowe kopie pliku hardlinkami.\n\t- --max-depth=N: Opcjonalny parametr pozwalający ustawić maksymalną głębokość rekurencyjnego skanowania katalogów.\n\t- --hash-algo=ALGO: Pozwala wybrać algorytm haszowania do porównania plików, np. md5sum (domyślny), sha1sum, sha256sum. Jeśli polecenie XXX nie istnieje wówczas drukujemy "XXX not supported". i zakańczamy pracę programu.\n\t- --help: jeśli opcja obecna, opis użycia programu **niezależnie od obecności innych opcji i zakończenie pracy programu**\n'
      exit 0
    fi
  done
}

check_for_help_apperance "$@"

ARGS=$(getopt -o "" -l "replace-with-hardlinks,max-depth:,hash-algo:,help" -- "$@")

eval set -- "$ARGS"

for arg in "$@"; do
  case "$arg" in
    --replace-with-hardlinks)
      shift
      ;;


    --max-depth)
      if [[ -z "$2" || "$2" == -* ]]; then
        echo "--max-depth option require a number of the recursion depth"
        exit 1
      fi

      if [[ ! "$2" =~ [0-9]+ ]]; then
        echo "Opcja musi byc integerem"
        exit 1
      fi

      shift 2
      ;;


    --hash-algo)
     if [[ -z "$2" || "$2" == -* ]]; then
        echo "--hash-algo option require a name of algorithm"
        exit 1
      fi
      shift 2
      ;;


    --)
      shift
      break
      ;;


    *)
      echo "Nieznana opcja: $1"
      exit 1
      ;;


  esac
done