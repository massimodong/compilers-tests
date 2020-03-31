check() {
	FL1=$(head -1 $1)
	FL2=$(head -1 $2)

	if [ ${FL1:0:1} == 'P' ]; then ## Starts with 'P', parse ok
		if diff $1 $2 >/dev/null; then
			exit 0
		else
			exit 1
		fi
	else                            ## parse failed
		if [ ${FL2:0:1} == 'P' ]; then ## But if you output 'P', then mismatch
			exit 1
		else
			## check if your output ends with "."
			if ! [ ${FL2: -1} == '.' ]; then
				echo -e "${RED}${BOLD}Error: your output should end with \".\"${NC}${NORMAL}"
				exit 1
			fi
			exit 0
		fi
	fi

}
