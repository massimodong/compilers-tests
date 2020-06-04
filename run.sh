#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

cd $(dirname $0)

echo "Making(Updating) irsim"
make -C irsim

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

report_error(){
  echo -e "${RED}${BOLD}test [$(basename $fcmm)]" "$1" "${NC}${NORMAL}"
  read -p "Enter [c] to continue, or [Enter] to abort: " txt
  if [ -z "$txt" ] || [ $txt != 'c' ]
  then
    exit 1
  fi
}

if timeout --help > /dev/null 2>&1; then #if has `timeout` command
    PREFIX="timeout 10 ";
else
    echo "timeout command is not support in current environment"
    echo "running time will not be counted"
    PREFIX="";
fi;

echo -n 0 > workdir/count
for fcmm in ./tests/*.cmm; do
  cp $fcmm ./workdir/a.cmm
  cp ${fcmm%.cmm}.json ./workdir/a.json

  if $PREFIX $RUN ./workdir/a.cmm  ./workdir/a.ir 2>&1; then
      true; #do nothing
  else
      report_error "RE or TLE"
      continue
  fi;

  if $PREFIX python3 ./check.py; then
    echo test [$(basename $fcmm)] matched
  else
    report_error "mismatch or TLE"
    continue
  fi
done

echo -n "irsim executes about "
cat workdir/count
echo " instructions"
