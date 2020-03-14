#!/bin/bash

if [ -z $1 ]
then
  echo "Please run \"run.sh\""
  exit 1;
fi

RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

FL1=$(head -1 $1)
FL2=$(head -1 $2)

if [ ${FL1:0:1} == 'P' ] ## Starts with 'P', parse ok
then
  if diff $1 $2 > /dev/null; then
    exit 0;
  else
    exit 1;
  fi
else ## parse failed
  if [ ${FL2:0:1} == 'P' ] ## But if you output 'P', then mismatch
  then
    exit 1;
  else
    ## check if your output ends with "."
    if ! [ ${FL2: -1} == '.' ]
    then
      echo -e "${RED}${BOLD}Error: your output should end with \".\"${NC}${NORMAL}"
      exit 1
    fi
    exit 0;
  fi
fi
