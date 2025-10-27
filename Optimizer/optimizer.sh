#!/bin/bash
# Jakub Heczko

HARDLINKS_FLAG=0
INTERACTIVE_FLAG=0
MAX_DEPTH="no"
HASH_ALGO="md5sum"
DIRNAME="./"
SEPARATOR="#####"

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
  ARGS=$(getopt -o "" -l "replace-with-hardlinks,max-depth:,hash-algo:,help,interactive" -- "$@" 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed to parse arguments"
    exit 1
  fi

  eval set -- "$ARGS"

  while true; do
    case "$1" in

      --replace-with-hardlinks)
        HARDLINKS_FLAG=1
        shift
        ;;


      --interactive)
        INTERACTIVE_FLAG=1
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

        MAX_DEPTH=$($2+1)
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
  local separator="$SEPARATOR"
  IFS="$separator" read -r -a result <<< "$value"
  printf '%s\n' "${result[@]}"
}


function size(){
  local file=$1
  echo $(stat -c%s "$1")
}

#function length_search(){
#  local working_directory="${1%/}"
#  local depth=$2
#  local files=$(find "$working_directory" -mindepth 1 -maxdepth 1)
#
#  # jesli jendak wszystko potrzeba aby zrobic >= zamiast > to wtedy -ge
#  for file in $files; do
#    if [[ $depth -gt $MAX_DEPTH && $MAX_DEPTH != "no" ]]; then
#      return
#    fi
#
#    if [[ $file == '.' || $file == '..' ]]; then
#      continue
#    fi
#
#    if [[ -d $file ]]; then
#      length_search "$file" "$((depth+1))"
#    elif [[ -f $file ]]; then
#      size_map[$(size "$file")]+="$SEPARATOR$file$SEPARATOR"
#      NUMBER_OF_PROCCESSED_FILES=$((NUMBER_OF_PROCCESSED_FILES+1))
#    fi
#  done
#}

function length_search(){
  local working_directory="${1%/}"
  local depth=$2
  local files=$(find "$working_directory" -mindepth 1 -maxdepth 1)

  # jesli jendak wszystko potrzeba aby zrobic >= zamiast > to wtedy -ge
  for file in $files; do
    if [[ $depth -gt $MAX_DEPTH && $MAX_DEPTH != "no" ]]; then
      return
    fi

    if [[ $file == '.' || $file == '..' ]]; then
      continue
    fi

    if [[ -d $file ]]; then
      length_search "$file" "$((depth+1))"
    elif [[ -f $file ]]; then
      size_map[$(size "$file")]+="$SEPARATOR$file$SEPARATOR"
      NUMBER_OF_PROCCESSED_FILES=$((NUMBER_OF_PROCCESSED_FILES+1))
    fi
  done
}


function hash_search(){
  for key in "${!size_map[@]}"; do
    local files_raw=${size_map[$key]}
    local files_arr=$(split $files_raw)
    for file in $files_arr; do
        file_hash="$(hash $file)"
        hash_map[$file_hash]+="$SEPARATOR$file$SEPARATOR"
    done
  done
}

function cmp_search(){
  local tmp_file1=$(mktemp tmpXXXXXXXXX)
  local tmp_file2=$(mktemp tmpXXXXXXXXX)

  for hash in "${!hash_map[@]}";do
    local files_raw=${hash_map[$hash]}
    local files_arr=($(split "$files_raw"))


    if [[ ${#files_arr[@]} -eq 1 ]]; then
      #echo Jestem niby jeden dlugosc ${hash_map[$hash]}
      #echo $files_arr
      continue
    fi

    keys=("${files_arr[@]}")

    # redukcja
    for ((i=0; i<${#keys[@]}; i++)); do
      for ((j=i+1; j<${#keys[@]}; j++)); do
        file1="${keys[$i]}"
        file2="${keys[$j]}"

        # trzeba sprawdzic po inodach czy wskazujemy na ten sam odcinek w pamieci czy razczej sa to rozne pliki, bo jesli rozne to jeden kasujemy i robimy do pierwszego hardlinka :D
        inode1=$(stat -c '%d:%i' "$file1")
        inode2=$(stat -c '%d:%i' "$file2")

        if cmp -s "$file1" "$file2" && [[ "$inode1" != "$inode2" ]]; then
          cp "$file1" "$tmp_file1"
          cp "$file2" "$tmp_file2"
          #echo "Identyczne pliki z roznymi inodami: $file1 $file2"
          NUMBER_OF_FOUND_DUPLICATES=$((NUMBER_OF_FOUND_DUPLICATES+1))


          if [[ $INTERACTIVE_FLAG -eq 1 ]]; then
              read -p "Czy chcesz utworzyć hardlink: $file2 -> $file1 ? [t/N] " reply
              reply=${reply,,}  # zmiana na małe litery
              if [[ "$reply" != "t" ]]; then
                  echo "Pominięto $file2 -> $file1"
                  continue  # pomiń tworzenie hardlinka
              fi
          fi

          # Dobra maly opis co tutaj sie dzieje, najpierw usuwamy wczesniej skopiowany do pliku tymaczosego plik, natepnie robimy hardlinka do plik1, jesli hardlinka nie da sie zrobic, to wtedy zwracamy plik drugi na miejsce plik2, usuwamy plik1 nastepnie robimy hardlinka na pliku2.
          if [[ $HARDLINKS_FLAG -eq 1 ]]; then
            if rm "$file2";ln -f "$file1" "$file2" && [[ -f "$file2" ]]; then
                #echo -e "\t-Hardlink utworzony i plik istnieje"
                NUMBER_OF_REPLACED_DUPLICATES=$((NUMBER_OF_REPLACED_DUPLICATES+1))
            elif  cp "$tmp_file2" "$file2";rm "$file1";ln -f "$file2" "$file1" && [[ -f "$file1" ]]; then
                #echo -e "\t-Hardlink utworzony i plik istnieje"
                NUMBER_OF_REPLACED_DUPLICATES=$((NUMBER_OF_REPLACED_DUPLICATES+1))
            fi

            if [[ -f "$file1" ]];then
              cp "$tmp_file1" "$file1"
            fi

            if [[ -f "$file2" ]];then
              cp "$tmp_file2" "$file2"
            fi

          fi
        fi
      done
    done
  done
  rm "$tmp_file1" "$tmp_file2"
}

function print_stat(){
  echo "Liczba przetworzonych plikow: $NUMBER_OF_PROCCESSED_FILES"
  echo "Liczba znalezionych duplikatow: $NUMBER_OF_FOUND_DUPLICATES"
  echo "Liczba zastapionych duplikatow: $NUMBER_OF_REPLACED_DUPLICATES"
}

# =================================================


check_for_help_apperance "$@"

parse_args "$@"

if [[ ! -d $DIRNAME ]]; then
  echo "Given file is not directory"
  exit 1
fi

length_search "$DIRNAME" 0

hash_search

#for key in "${!size_map[@]}"; do
#    value="${size_map[$key]}"
#    echo "Klucz: $key -> Wartość: $value"
#done
#
#for key in "${!hash_map[@]}"; do
#    value="${hash_map[$key]}"
#    echo "Klucz: $key -> Wartość: $value"
#done

cmp_search

print_stat