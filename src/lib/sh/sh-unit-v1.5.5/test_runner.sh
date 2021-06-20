#!/bin/bash

source ../../../bootstrap.sh

include_lib sh-logger

ESC_CHAR='\033'

RED=$ESC_CHAR'[0;31m'
GREEN=$ESC_CHAR'[0;32m'
YELLOW=$ESC_CHAR'[0;93m'
NC=$ESC_CHAR'[0m' # No Color

string_start_with(){
	STRING=$1
	SUBSTRING=$2
	if [[ $STRING == "$SUBSTRING"* ]]; then
		return 0;
	else
		return 1;
	fi
}


run_all_tests_in_this_script() {

	TEST_CASE_TOTAL_COUNT=0;
	TEST_CASE_SUCCESS_COUNT=0;
	TEST_CASE_FAIL_COUNT=0;

	SCRIPT_NAME_TO_RUN_TESTS="$(basename "${BASH_SOURCE[1]}")"

	echo "-------------------------------------------------------------"
	echo "Running tests in $SCRIPT_NAME_TO_RUN_TESTS ..."
	echo "-------------------------------------------------------------"

    if [ $# -eq 0 ];  then
	    FUNCTIONS_TO_TEST=( `grep -E '^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)' $SCRIPT_NAME_TO_RUN_TESTS | tr \(\)\}\{ ' ' | sed 's/^[ \t]*//;s/[ \t]*$//'` );
    else 
    	FUNCTIONS_TO_TEST=( $@ );    
    fi
    
    #echo "Have ${#FUNCTIONS_TO_TEST[*]} test cases"
    #for FUNCTION_NAME in ${FUNCTIONS_TO_TEST[@]}
	#do
	#    echo "|$FUNCTION_NAME|"
	#done

	for FUNCTION_NAME in ${FUNCTIONS_TO_TEST[@]}
	do
		if (string_start_with $FUNCTION_NAME "test_"); then
			$FUNCTION_NAME
		fi
		
		#TODO: Fix this part before release - start
		#if [[ $? != 0 ]]; then
		#	TEST_CASE_FAIL_COUNT=$((TEST_CASE_FAIL_COUNT+1))
		#else
		#	TEST_CASE_SUCCESS_COUNT=$((TEST_CASE_SUCCESS_COUNT+1))
		#fi
		#TODO: Fix this part before release - end
		
		TEST_CASE_TOTAL_COUNT=$((TEST_CASE_TOTAL_COUNT+1))
	done
	
	echo "-------------------------------------------------------------"
	echo "Finish. $TEST_CASE_TOTAL_COUNT tests executed"
	
	#TODO: Fix this part before release - start
	#echo " Success: $TEST_CASE_SUCCESS_COUNT"
	#echo " Fail:    $TEST_CASE_FAIL_COUNT"
	#TODO: Fix this part before release - end
	
	if [[ $TEST_STATUS == "FAIL" ]]; then 
		echo -e "Result: ${RED}$TEST_STATUS${NC}"
	else		
		echo -e "Result: ${GREEN}$TEST_STATUS${NC}"
	fi
	echo "-------------------------------------------------------------"
	
	if [[ $TEST_STATUS == "FAIL" ]]; then
		return 1;
	else		
		return 0;
	fi
	
}

