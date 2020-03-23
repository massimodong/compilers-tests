#!/bin/bash

if [ -z $1 ]
then
  echo "Usage: $0 path_to_parser_binary"
  exit -1
fi

if ! [ -x $1 ]
then
  echo "Error: file \"$1\" is not executable"
  exit -1
fi

RUN=$1
CODE=0

mkdir -p ./workdir

for fcmm in ./tests/*.cmm; do
  cp $fcmm ./workdir/a.cmm
  cp ${fcmm%.cmm}.out ./workdir/a.out

  $RUN ./workdir/a.cmm > ./workdir/b.out 2>&1

  if ./check.sh ./workdir/a.out ./workdir/b.out; then
    echo test [$(basename $fcmm)] matched
  else
    echo -e "test [$(basename $fcmm)] mismatch"
    diff ./workdir/a.out ./workdir/b.out | head -10
    CODE=-1
  fi
done

exit $CODE
