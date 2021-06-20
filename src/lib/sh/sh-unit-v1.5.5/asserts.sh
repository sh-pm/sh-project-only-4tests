#!/bin/bash
# v1.5.0 - Build with sh-pm

 

ESC_CHAR='\033'

RED=$ESC_CHAR'[0;31m'
GREEN=$ESC_CHAR'[0;32m'
YELLOW=$ESC_CHAR'[0;93m'
NC=$ESC_CHAR'[0m' # No Color

TEST_STATUS=OK

get_caller_info(){
	echo "${BASH_SOURCE[2]} - ${FUNCNAME[2]}"
}

assert_equals(){
	log_trace "PARAM1: |$1|"
	log_trace "PARAM2: |$2|"

	if [[ $1 == $2 ]]; then
		echo -e "`get_caller_info`: ${GREEN}Assert Success!${NC}"
	else
		echo -e "`get_caller_info`: ${RED}Assert FAIL!${NC}"
		echo -e "${RED}     ${FUNCNAME[0]}: |$1| is NOT EQUALs |$2|${NC}" 
		TEST_STATUS="FAIL"
	fi
}


assert_true(){
    local VALUE=$1
    local MSG_IF_FAIL=$2
    
    if [[ -z $VALUE ]]; then
		LAST_FUNCTION_STATUS_EXECUTION=`echo $?`;
		VALUE=$LAST_FUNCTION_STATUS_EXECUTION
    fi

	if [[ $VALUE == "0" ]]; then
		echo -e "`get_caller_info`: ${GREEN}Assert Success!${NC}"
		return 0;
	else
		if [[ -z $MSG_IF_FAIL ]]; then
	    	echo -e "`get_caller_info`: ${RED}Assert FAIL!${NC}"
	    else 
	    	echo -e "`get_caller_info`: ${RED}Assert FAIL! $1${NC}"
	    fi
		echo -e "${RED}     ${FUNCNAME[0]}: |$VALUE| is NOT true${NC}"
		TEST_STATUS="FAIL"
		return 1;
	fi
}	

assert_false(){
	local VALUE=$1
    local MSG_IF_FAIL=$2
    
    if [[ -z $VALUE ]]; then
		LAST_FUNCTION_STATUS_EXECUTION=`echo $?`;
		VALUE=$LAST_FUNCTION_STATUS_EXECUTION
    fi

	if [[ $VALUE == "0" ]]; then
		if [[ -z $MSG_IF_FAIL ]]; then
	    	echo -e "`get_caller_info`: ${RED}Assert FAIL!${NC}"
	    else 
	    	echo -e "`get_caller_info`: ${RED}Assert FAIL! $1${NC}"
	    fi
	    echo -e "${RED}     ${FUNCNAME[0]}: |$VALUE| is NOT false${NC}"
		TEST_STATUS="FAIL"
		return 1;
	else
		echo -e "`get_caller_info`: ${GREEN}Assert Success!${NC}"
		return 0;
	fi
}

assert_fail(){
    if [[ -z $1 ]]; then
    	echo -e "`get_caller_info`: ${RED}Assert FAIL!${NC}"
    else 
    	echo -e "`get_caller_info`: ${RED}Assert FAIL! $1${NC}"
    fi
	TEST_STATUS="FAIL"
}

assert_success(){
    echo -e "`get_caller_info`: ${GREEN}Assert Success!${NC}"	
}



