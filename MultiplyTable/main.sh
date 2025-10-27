#!/bin/bash
#Jakub Heczko gr. 2

#set -x

# parse_input_arguments()
# Args:
# - $@: all of the input arguments
#
# Returns:
# two or one integer as first_number or second_number, those can be accesed globally
parse_input_arguments(){
  # Checking the amount of arguments
  if [[ $# -lt 1 ]]; then
    #echo "Have to give at least one argument"
    exit 1

  elif [[ $# -gt 2 ]]; then
    #echo "TO much arguments give at least 2"
    exit 1

  # If we have correct number of args then check if those are integers
  elif [[ $# -eq 1 ]];then
    if [[ $1 =~ ^[0-9]+$ ]]; then
      first_number=1
      second_number=$1
    else
      #echo "Passed argument is not integer"
      exit 1
    fi

  elif [[ $# -eq 2 ]];then
    if [[ $1 =~ ^[0-9]+$ && $2 =~ ^[0-9]+$ ]]; then
      # Check if arguments even make sense for example 7 and 2 are not acceptable but 7 and 2 are
      if [[ $(( $2-$1 )) -le 0 ]]; then
        #echo "Arguments does not make sense, You cannot make table from $1 to $2, instead give args in such sequence $2 to $1"
        exit 1
      fi
      first_number=$1
      second_number=$2
    else
      #echo "One of argument is not integer"
      exit 1
    fi
  fi
}

# print_headers()
# Args:
# - 1: gap size that is precalculated
#
# Returns:
# None
print_headers(){
  local gap_local=$1
  printf "%*s" "$gap_local" ""
  for ((i=first_number; i<second_number+1; i++)); do
    printf "%*s" "$gap_local" "$i"
  done
  echo
}



# print_rows()
# Args:
# - 1: gap size that is precalculated
#
# Returns:
# None
print_rows(){
  local gap_local=$1
  for ((i=first_number; i<second_number+1; i++)); do
    printf "%*s" "$gap_local" "$i"
    for ((j=first_number; j<second_number+1; j++)); do
      printf "%*s" "$gap_local" "$((i*j))"
    done
    echo
  done
}

# Main Optimizer
parse_input_arguments "$@"

longest_word=$((second_number*second_number))
gap=${#longest_word}
gap=$((gap+2))

print_headers "$gap"

print_rows "$gap"