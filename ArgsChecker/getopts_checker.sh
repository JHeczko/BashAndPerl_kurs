#!/bin/bash
# Jakub Heczko

getopts_string=""
optind=""

# check for unsuported q argument
function check_for_q_apperance(){
  for arg in "$@"; do
    if [[ "$arg" == "-q" ]]; then
      echo "Unsupported option: -q"
      exit 1
    fi
  done
}

function parse_args(){
  # creating getops string
  while getopts ":abcdefghjklmnprstuvwxyzABCDEFGHJKLMNPRSTUVWXYZi:o:" arg; do
    case "$arg" in

      [i,o])
        buf='-'$arg' present and set to "'$OPTARG'"'$'\n'
        getopts_string+="$buf"
        ;;


      [a-zA-Z])
          buf='-'$arg' present'$'\n'
          getopts_string+="$buf"
        ;;

      # no argument for arg options handler
      :)
        echo "-i -o options require a filename"
        exit 1
        ;;

      # not supported option handler
      \?)
        echo "Unsupported option: $OPTARG"
        exit 1
        ;;
    esac
  done;
  optind="$OPTIND"
}


function print_main_args() {
  local getopts_string_nonsorted=$getopts_string
  local getopts_string_sorted=""
  getopts_string_sorted=$(printf "%s" "$getopts_string_nonsorted" | sort -u)
  echo "$getopts_string_sorted"
}

function print_rest_args(){
  # printing additional arguments
  if [[ $# -gt 0 ]]; then
    echo "Arguments are:"
    count=1
    for additional_arg in "$@"; do
      echo "\$$count=$additional_arg"
      count=$((count+1))
    done
  fi
}




# ======== MAIN PROGRAM WORKFLOW ========
check_for_q_apperance "$@"

parse_args "$@"

print_main_args

# skipping the getopts parsed arguments
shift $(($optind-1))

print_rest_args "$@"

