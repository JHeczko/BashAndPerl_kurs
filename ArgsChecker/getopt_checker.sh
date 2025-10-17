#!/bin/bash
# Jakub Heczko

# -=-==-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-

# check_for_q_apperance()
# checkes if argument -q is in the params
#
# Input Arguments:
# - all program input parameters
function check_for_q_apperance(){
  for arg in "$@"; do
    if [[ "$arg" == "-q" ]]; then
      echo "Unsupported option: -q"
      exit 1
    fi
  done
}

# check_for_help_apperance()
# checkes if argument -help is in the params
#
# Input Arguments:
# - all program input parameters
function check_for_help_apperance(){
  for arg in "$@"; do
    if [[ $arg == "--help" ]]; then
      echo "Witam w pomocy"
      exit 0
    fi
  done
}

# print_rest_args()
# printing additional arguments
#
# Input Arguments:
# - takes all of the rest arguments that was left from parsing and are no option arguments
function print_rest_args(){
  if [[ $# -gt 0 ]]; then
    echo "Arguments are:"
    count=1
    for additional_arg in "$@"; do
      echo "\$$count=$additional_arg"
      count=$((count+1))
    done
  fi
}

# print_main_args()
# prints all program options sorted alphabeticly
#
# Input Arguments:
# - string with formatted option parameters (\n at the end of every option segment)
function print_main_args() {
  local getopts_string_nonsorted=$1
  local getopts_string_sorted=""
  getopts_string_sorted=$(printf "%s" "$getopts_string_nonsorted" | sort -u)
  echo "$getopts_string_sorted"
}
# -=-==-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-



# ======== MAIN PROGRAM WORKFLOW ========
getopt_string=""


check_for_help_apperance "$@"
check_for_q_apperance "$@"

ARGS=$(getopt -o abcdefghjklmnprstuvwxyzi:o: -l help -- "$@")
# -o krotkie opcje
# -l dlugie opcje
# -- znak ucieczki
# $@ podanie argumentow do parsowania

# ustawienie nowych argumentów w skrypcie
eval set -- "$ARGS"


while true; do
  case "$1" in
    -[o,i])
      buf='-'$1' present and set to "'$2'"'$'\n'
      getopt_string+="$buf"
      shift 2
      ;;
    -[a-zA-Z])
      buf='-'$1' present'$'\n'
      getopt_string+="$buf"
      shift 1
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

print_main_args "$getopt_string"

# shellcheck disable=SC2145
print_rest_args "$@"
