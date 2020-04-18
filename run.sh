#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PYTHON='python'
CC='gcc'

cd $(dirname $0)

if ! [ -z $1 ]
then
  rm ./workdir/saved_binary.sh 2> /dev/null
fi

RUN=$1
CODE=0

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

mkdir -p ./workdir

echo "RUN=$RUN" > ./workdir/saved_binary.sh

report_error(){
  echo -e "${RED}${BOLD}test [$(basename $fcmm)]" "$1" "${NC}${NORMAL}"
  read -p "Enter [c] to continue, or [Enter] to abort: " txt
  if [ -z "$txt" ] || [ $txt != 'c' ]
  then
    exit 1
  fi
}

for fcmm in ./tests/*.cmm; do
  cp $fcmm ./workdir/a.cmm
  cp ${fcmm%.cmm}.in ./workdir/a.in
  cp template.c ./workdir/template.c

  if timeout --help > /dev/null 2>&1; then #if has `timeout` command
    if timeout 2 $RUN ./workdir/a.cmm ./workdir/a.ir; then
      true; #do nothing
    else
      report_error "RE or TLE when compile"
      continue
    fi
  else
    if $RUN ./workdir/a.cmm ./workdir/a.ir; then
      true; #do nothing
    else
      report_error "RE when compile"
      continue
    fi
  fi

  if timeout --help > /dev/null 2>&1; then #if has `timeout` command
    if timeout 5 $CC ./workdir/template.c -o ./workdir/std.out; then
      ./workdir/std.out < ./workdir/a.in > ./workdir/ans.out
    else
      report_error "RE or TLE when compile by GCC"
      continue
    fi
  else
    if $CC ./workdir/template.c -o ./workdir/std.out; then
      ./workdir/std.out < ./workdir/a.in > ./workdir/ans.out
    else
      report_error "RE when compile by GCC"
      continue
    fi
  fi

  if timeout --help > /dev/null 2>&1; then #if has `timeout` command
    if timeout 8 $PYTHON ./irsim.py ./workdir/a.ir < ./workdir/a.in > ./workdir/a.out; then
      true; #do nothing
    else
      report_error "RE or TLE when execute IR"
      continue
    fi
  else
    if $PYTHON ./irsim.py ./workdir/a.ir < ./workdir/a.in > ./workdir/a.out; then
      true; #do nothing
    else
      report_error "RE when execute IR"
      continue
    fi
  fi

  if diff ./workdir/ans.out ./workdir/a.out --strip-trailing-cr > /dev/null; then
    echo test [$(basename $fcmm)] matched
  else
    diff ./workdir/ans.out ./workdir/a.out --strip-trailing-cr | head -10
    CODE=-1
    report_error "mismatch"
  fi
done

exit $CODE