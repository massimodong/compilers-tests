#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

cd $(dirname $0)

if ! [ -z $1 ]
then
  rm ./workdir/saved_binary.sh 2> /dev/null
fi

RUN=$1

if [ -e ./workdir/saved_binary.sh ]
then
  source ./workdir/saved_binary.sh
fi

if [ -z $RUN ]
then
  echo "Usage: $0 path_to_parser_binary"
  rm ./workdir/saved_binary.sh 2> /dev/null
  exit 0
fi

if ! [ -x $RUN ]
then
  echo "Error: file \"$RUN\" is not executable"
  rm ./workdir/saved_binary.sh 2> /dev/null
  exit 0
fi

echo "RUN=$RUN" > ./workdir/saved_binary.sh

mkdir -p ./workdir

for fcmm in ./tests/*.cmm; do
  cp $fcmm ./workdir/a.cmm
  cp ${fcmm%.cmm}.json ./workdir/a.json

  $RUN ./workdir/a.cmm > ./workdir/a.out 2>&1

  if python3 ./check.py; then
    echo test [$(basename $fcmm)] matched
  else
    echo -e "${RED}${BOLD}test [$(basename $fcmm)] mismatch${NC}${NORMAL}"
    read -p "Enter [c] to continue, or [Enter] to abort: " txt
    if [ -z "$txt" ] || [ $txt != 'c' ]
    then
      exit 0
    fi
  fi
done
