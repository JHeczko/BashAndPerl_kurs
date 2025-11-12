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
declare -A cmp_map

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
  local dir="$1"
  local text=$(base64 -w0 "$dir")
  echo -n "$text" | $HASH_ALGO | awk '{print $1}'
}

function split() {
  local value="$1"
  local separator="$SEPARATOR"
  IFS="$separator" read -r -a result <<< "$value"
  for item in "${result[@]}"; do
    [[ -z "$item" ]] && continue
    printf '%s\n' "$item"
  done
}


function size(){
  local file=$1
  echo "$(stat -c%s "$1")"
}

function order_con() {
    local str1="$1"
    local str2="$2"

    if [[ "$str1" < "$str2" ]]; then
        echo "${str1}_${str2}"
    else
        echo "${str2}_${str1}"
    fi
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

# function length_search(){
#   local working_directory="${1%/}"
#   local files
#   if [[ "$MAX_DEPTH" == "no" ]]; then
#       files=$(find "$working_directory" -type f -mindepth 1)
#   elif [[ "$MAX_DEPTH" =~ ^[0-9]+$ ]]; then
#       files=$(find "$working_directory" -type f -mindepth 1 -maxdepth $MAX_DEPTH)
#   fi

#   # jesli jendak wszystko potrzeba aby zrobic >= zamiast > to wtedy -ge
#   for file in $files; do
#     if [[ $file == '.' || $file == '..' ]]; then
#       continue
#     fi

#     if [[ -f $file ]]; then
#       #echo $file
#       size_map[$(size "$file")]+="$SEPARATOR$file$SEPARATOR"
#       NUMBER_OF_PROCCESSED_FILES=$((NUMBER_OF_PROCCESSED_FILES+1))
#     fi
#   done
# }


function length_search(){
  local working_directory="${1%/}"
  
  # Używamy -print0 aby poprawnie obsłużyć pliki z białymi znakami
  if [[ "$MAX_DEPTH" == "no" ]]; then
      while IFS= read -r -d '' file; do
        #echo "$file";
        if [[ -f "$file" ]]; then
          size_map[$(size "$file")]+="$SEPARATOR$file$SEPARATOR"
          NUMBER_OF_PROCCESSED_FILES=$((NUMBER_OF_PROCCESSED_FILES+1))
        fi
      done < <(find "$working_directory" -mindepth 1 -type f -print0)

  elif [[ "$MAX_DEPTH" =~ ^[0-9]+$ ]]; then
      while IFS= read -r -d '' file; do
        #echo "$file";
        if [[ -f "$file" ]]; then
          size_map[$(size "$file")]+="$SEPARATOR$file$SEPARATOR"
          NUMBER_OF_PROCCESSED_FILES=$((NUMBER_OF_PROCCESSED_FILES+1))
        fi
      done < <(find "$working_directory" -type f -mindepth 1 -maxdepth $MAX_DEPTH -print0)
  fi

  #echo "Wychodze z length_search"
}


function hash_search() {
  for key in "${!size_map[@]}"; do
    local files_raw=${size_map[$key]}
    while IFS= read -r file; do
      #echo "Przetwarzam: $file"
      file_hash="$(hash "$file")"
      hash_map[$file_hash]+="$SEPARATOR$file$SEPARATOR"
    done < <(split "$files_raw")
  done
}

function cmp_search(){
  local tmp_file1
  local tmp_file2
  if [[ $HARDLINKS_FLAG -eq 1 ]]; then
    tmp_file1=$(mktemp tmpXXXXXXXXX)
    tmp_file2=$(mktemp tmpXXXXXXXXX)
  fi

  for hash in "${!hash_map[@]}";do
    local files_raw=${hash_map[$hash]}

    # ✅ zamiast "local files_arr=($(split ...))" — użyj mapfile, które obsługuje spacje
    local files_arr=()
    while IFS= read -r line; do
      [[ -n "$line" ]] && files_arr+=("$line")
    done < <(split "$files_raw")

    if [[ ${#files_arr[@]} -eq 1 ]]; then
      continue
    fi

    keys=("${files_arr[@]}")

    # redukcja
    for ((i=0; i<${#keys[@]}; i++)); do
      for ((j=i+1; j<${#keys[@]}; j++)); do
        file1="${keys[$i]}"
        file2="${keys[$j]}"

        inode1=$(stat -c '%d:%i' "$file1")
        inode2=$(stat -c '%d:%i' "$file2")

        if cmp -s "$file1" "$file2" && [[ "$inode1" != "$inode2" ]]; then
          if [[ $HARDLINKS_FLAG -eq 1 ]]; then
            cp "$file1" "$tmp_file1"
            cp "$file2" "$tmp_file2"
          fi

          if [[ ! -v ${cmp_map[$(order_con "$file1" "$file2")]} ]]; then
            cmp_map[$(order_con "$file1" "$file2")]="git"
            NUMBER_OF_FOUND_DUPLICATES=$((NUMBER_OF_FOUND_DUPLICATES+1))
          fi

          if [[ $INTERACTIVE_FLAG -eq 1 ]]; then
              read -p "Czy chcesz utworzyć hardlink: $file2 -> $file1 ? [t/N] " reply
              reply=${reply,,}
              if [[ "$reply" != "t" ]]; then
                  echo "Pominięto $file2 -> $file1"
                  continue
              fi
          fi

          if [[ $HARDLINKS_FLAG -eq 1 ]]; then
            if rm "$file2";ln -f "$file1" "$file2" && [[ -f "$file2" ]]; then
                NUMBER_OF_REPLACED_DUPLICATES=$((NUMBER_OF_REPLACED_DUPLICATES+1))
            elif  cp "$tmp_file2" "$file2";rm "$file1";ln -f "$file2" "$file1" && [[ -f "$file1" ]]; then
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

  if [[ $HARDLINKS_FLAG -eq 1 ]]; then
    rm "$tmp_file1" "$tmp_file2"
  fi
}


function cmp_search2() {
  local tmp_file1
  local tmp_file2
  if [[ $HARDLINKS_FLAG -eq 1 ]]; then
    tmp_file1=$(mktemp tmpXXXXXXXXX)
    tmp_file2=$(mktemp tmpXXXXXXXXX)
  fi

  for hash in "${!hash_map[@]}"; do
    local files_raw=${hash_map[$hash]}
    # split już poprawiony – zakładamy, że nie daje pustych
    local files_arr=($(split "$files_raw"))

    # jeśli tylko jeden plik w grupie, pomijamy
    if [[ ${#files_arr[@]} -le 1 ]]; then
      continue
    fi

    # W tej grupie może być wiele duplikatów
    # Sprawdzamy wszystkie pliki w grupie względem siebie
    for ((i=0; i<${#files_arr[@]}; i++)); do
      file1="${files_arr[$i]}"
      for ((j=i+1; j<${#files_arr[@]}; j++)); do
        file2="${files_arr[$j]}"

        inode1=$(stat -c '%d:%i' "$file1")
        inode2=$(stat -c '%d:%i' "$file2")

        # sprawdzenie zawartości
        if cmp -s "$file1" "$file2" && [[ "$inode1" != "$inode2" ]]; then
          # kopiowanie tymczasowe jeśli hardlink
          if [[ $HARDLINKS_FLAG -eq 1 ]]; then
            cp "$file1" "$tmp_file1"
            cp "$file2" "$tmp_file2"
          fi

          # zliczanie duplikatów dla KAŻDEGO wystąpienia
          NUMBER_OF_FOUND_DUPLICATES=$((NUMBER_OF_FOUND_DUPLICATES+1))

          # unikanie powtórek przy hardlinkach
          if [[ ! -v cmp_map[$(order_con "$file1" "$file2")] ]]; then
            cmp_map[$(order_con "$file1" "$file2")]=1
          fi

          if [[ $INTERACTIVE_FLAG -eq 1 ]]; then
            read -p "Czy chcesz utworzyć hardlink: $file2 -> $file1 ? [t/N] " reply
            reply=${reply,,}
            if [[ "$reply" != "t" ]]; then
              echo "Pominięto $file2 -> $file1"
              continue
            fi
          fi

          if [[ $HARDLINKS_FLAG -eq 1 ]]; then
            if rm "$file2"; ln -f "$file1" "$file2" && [[ -f "$file2" ]]; then
              NUMBER_OF_REPLACED_DUPLICATES=$((NUMBER_OF_REPLACED_DUPLICATES+1))
            elif cp "$tmp_file2" "$file2"; rm "$file1"; ln -f "$file2" "$file1" && [[ -f "$file1" ]]; then
              NUMBER_OF_REPLACED_DUPLICATES=$((NUMBER_OF_REPLACED_DUPLICATES+1))
            fi

            [[ -f "$file1" ]] && cp "$tmp_file1" "$file1"
            [[ -f "$file2" ]] && cp "$tmp_file2" "$file2"
          fi
        fi
      done
    done
  done

  if [[ $HARDLINKS_FLAG -eq 1 ]]; then
    rm "$tmp_file1" "$tmp_file2"
  fi
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

length_search "$DIRNAME"

# for key in "${!size_map[@]}"; do
#    value="${size_map[$key]}"
#    echo "Klucz: $key -> Wartość: $value"
# done

hash_search

# for key in "${!hash_map[@]}"; do
#    value="${hash_map[$key]}"
#    echo "Klucz: $key -> Wartość: $value"
# done

cmp_search

print_stat