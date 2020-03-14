#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

if [ -z $1 ]
then
  echo "Usage: $0 path_to_parser_binary"
  exit 0
fi

if ! [ -x $1 ]
then
  echo "Error: file \"$1\" is not executable"
  exit 0
fi

mkdir -p ./workdir

for fcmm in ./tests/*.cmm; do
  cp $fcmm ./workdir/a.cmm
  cp ${fcmm%.cmm}.out ./workdir/a.out

  $1 ./workdir/a.cmm > ./workdir/b.out

  if ./check.sh ./workdir/a.out ./workdir/b.out; then
    echo test [$(basename $fcmm)] matched
  else
    echo -e "${RED}${BOLD}test [$(basename $fcmm)] mismatch${NC}${NORMAL}"
    diff ./workdir/a.out ./workdir/b.out | head -10
    read -p "Enter [c] to continue, or [Enter] to abort: " txt
    if [ -z "$txt" ] || [ $txt != 'c' ]
    then
      exit 0
    fi
  fi
done
