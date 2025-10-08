#!/bin/bash
#Jakub Heczko gr. 2

set -x

# Checking the amount of arguments
if [[ $# -lt 1 ]]; then
  echo "Have to give at least one argument"
  exit 1

elif [[ $# -gt 2 ]]; then
  echo "TO much arguments give at least 2"
  exit 1

# If we have correct number of args then check if those are integers
elif [[ $# -eq 1 ]];then
  if [[ $1 =~ ^[0-9]+$ ]]; then
    first_number=$1
  else
    echo "Passed argument is not integer"
    exit 1
  fi

elif [[ $# -eq 2 ]];then
  if [[ $1 =~ ^[0-9]+$ && $2 =~ ^[0-9]+$ ]]; then
    first_number=$1
    second_number=$2
  else
    echo "One of argument is not integer"
    exit 1
  fi
fi

# Check if arguments even make sense for example 7 and 2 are not acceptable but 7 and 2 are
if [[ $(( second_number-first_number )) -le 0 ]]; then
  echo "Arguments does not make sense, You cannot make table from $1 to $2, instead give args in such sequence $2 to $1"
  exit 1
fi


echo "$first_number"
echo "$second_number"