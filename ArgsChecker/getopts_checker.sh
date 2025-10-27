#!/bin/bash
# Jakub Heczko

getopts_string=""
optind=""

# check_for_q_apperance()
# checkes if argument -q is in the params
#
# Input Arguments:
# - all Optimizer input parameters
function check_for_q_apperance(){
  for arg in "$@"; do
    if [[ "$arg" == "-q" ]]; then
      echo "Unsupported option: -q"
      exit 1
    fi
  done
}


# parse_args()
# parses all the arguments of the Optimizer and then making whole string out of them
#
# Input Arguments:
# - all Optimizer input parameters
function parse_args(){
  # creating getops string
  while getopts ":abcdefghjklmnprstuvwxyzABCDEFGHJKLMNPRSTUVWXYZi:o:" arg; do
    case "$arg" in


      [i,o])
        # checking if the argument for option is not another argument
        if [[ -z "$OPTARG" || "$OPTARG" == -* ]]; then
          echo "-i -o options require a filename"
          exit 1
        fi
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

# print_main_args()
# prints all program options sorted alphabetically
#
# Input Arguments:
# - string with formatted option parameters (\n at the end of every option segment)
function print_main_args() {
  local getopts_string_nonsorted=$1
  local getopts_string_sorted=""
  getopts_string_sorted=$(printf "%s" "$getopts_string_nonsorted" | sort -u)
  echo "$getopts_string_sorted"
}


# print_rest_args()
# printing additional arguments
#
# Parameters:
# - takes all of the rest arguments that was left from parsing and are no option arguments
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

print_main_args "$getopts_string"

# skipping the getopts parsed arguments
shift $(($optind-1))

print_rest_args "$@"

