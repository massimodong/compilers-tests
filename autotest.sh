#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

QUIET=false
TEST_NUM=1
script_path=$(dirname "$0")
workdir=${script_path}/workdir
test_prefix=${script_path}/tests/test
check_prefix=${script_path}/checks/check
NAME=""
LOGFILE=${workdir}/autotest.log

usage() {
	echo "Usage: $(basename $0) [-h] [-q] [parser]"
}

set -- $(getopt -n autotest.sh -o qht:n: -l quiet,help,test:,name: -u -- "$@")

if [ $? -ne 0 ]; then
	usage
	exit -1
fi

while true; do
	case "$1" in
	-q | --quiet)
		QUIET=true
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	-t | --test)
		TEST_NUM=$2
		shift 2
		;;
	-n | --name)
		NAME=$2
		shift 2
		;;
	--)
		shift
		break
		;;
	esac
done

# Create workdir
if [[ !(-d ${workdir}) ]]; then
	mkdir -p ${workdir}
fi
testdir=${test_prefix}-${TEST_NUM}
checkfile=${check_prefix}-${TEST_NUM}.sh
if [[ !(-d ${testdir}) ]]; then
	echo "No test-set ${TEST_NUM}"
	exit -1
fi
if [[ !(-f ${checkfile}) ]]; then
	echo "check function for test-set ${TEST_NUM} not defined"
	exit -1
fi
source $checkfile
# Load Running Script
if [[ -z $1 ]]; then
	if [ -e ${workdir}/saved_binary.sh ]; then
		source ${workdir}/saved_binary.sh
	else
		usage
		exit -1
	fi
else
	RUN=$1
	echo "RUN=$(realpath $RUN)" >${workdir}/saved_binary.sh
fi
# Judge if executable
if ! [ -x $RUN ]; then
	echo "Error: file \"$RUN\" is not executable"
	exit -1
fi

# Test
CODE=0
TEST_SET=${testdir}/*.cmm
if [[ -n $NAME ]]; then
	TEST_SET=${testdir}/${NAME}.cmm
	if ! [[ -f $TEST_SET ]]; then
		echo -e "${RED}${BOLD}Test [$(basename $TEST_SET)] not exists${NC}${NORMAL}"
		exit -1
	fi
	QUIET=true
fi
if [[ -z "$(ls -A $testdir)" ]]; then
	echo -e "${RED}${BOLD}Test-set \"$(basename $testdir)\" contains no files${NC}${NORMAL}"
	exit -1
fi

echo "$(date)" > $LOGFILE
for fcmm in $TEST_SET; do
	cp $fcmm ${workdir}/a.cmm

	if ! [[ -f ${fcmm%.cmm}.out ]]; then
		echo -e "${RED}${BOLD}Test [$(basename $fcmm)] correct output not given${NC}${NORMAL}" |tee -a $LOGFILE
		CODE=-1
		if [[ "$QUIET" = false ]]; then
			read -p "Enter [c] to continue, other keys to abort: " txt
			if [ -z "$txt" ] || [ $txt != 'c' ]; then
				exit -1
			fi
		fi
		continue
	fi

	cp ${fcmm%.cmm}.out ${workdir}/a.out

	$RUN ${workdir}/a.cmm >${workdir}/b.out 2>&1

	if $(check ${workdir}/a.out ${workdir}/b.out); then
		echo "Test [$(basename $fcmm)] matched" |tee -a $LOGFILE
	else
		echo -e "${RED}${BOLD}Test [$(basename $fcmm)] mismatch${NC}${NORMAL}" |tee -a $LOGFILE
		diff ${workdir}/a.out ${workdir}/b.out | head -10
		CODE=-1
		if [[ "$QUIET" = false ]]; then
			read -p "Enter [c] to continue, other keys to abort: " txt
			if [ -z "$txt" ] || [ $txt != 'c' ]; then
				exit -1
			fi
		fi
	fi
done

exit $CODE
