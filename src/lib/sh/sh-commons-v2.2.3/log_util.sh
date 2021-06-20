#!/bin/bash
# v1.7.1 - Build with sh-pm



include_lib sh-logger

##
 # Shoud be executed inside a target function.
 #
 # @return .sh filename with call the function target 
 ##
get_script_caller_name(){
	echo "${BASH_SOURCE[2]}"
}

print_delimiter() {
    local SCRIPT_NAME=${BASH_SOURCE[2]}
    local MOMENT=$1

    log_info "========================================================="
    log_info "            $SCRIPT_NAME - $MOMENT"
    log_info "========================================================="
}

print_start_delimiter() {
	print_delimiter "Start"
}

print_end_delimiter() {
	print_delimiter "End"
}  

print_usage_help() {
	
    # Get function name
	local FUNCTION_NAME=${FUNCNAME[1]}

    # "main" word means that is not inside function 	
	if [[ "$FUNCTION_NAME" == "main" ]]; then
	    # get shell script filename
		FUNCTION_NAME=$( basename ${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]} )
	fi
	
	# Receive associative array
	eval "declare -A PARAMS_EXPECTED="${1#*=}
	
	local PARAM_NAME=''
	local PARAM_VALUE=''
	
	local PARAM_SINTAX=''
	
	echo "---------------------------------------------------------------------------------------------------------"
    echo "ERROR!"
    echo "Illegal number of parameters"
    echo ""
    echo "Expected:"
    echo ""
    
    for P_EXPECTED in "${!PARAMS_EXPECTED[@]}"; do 
		PARAM_NAME="$P_EXPECTED"				
		PARAM_SINTAX="$PARAM_SINTAX [$PARAM_NAME]"
	done
	echo "   $FUNCTION_NAME $PARAM_SINTAX"
	
	echo ""
    echo "Received:"
    echo ""
    
    local PARAMS_VALUES_RECEIVED=''
    
    # first param is the associative array
	for ((i = 2; i <= $#; i++ )); do
		PARAMS_VALUES_RECEIVED="$PARAMS_VALUES_RECEIVED ${!i}"
	done 
	
    echo "   $FUNCTION_NAME $PARAMS_VALUES_RECEIVED"
    echo "---------------------------------------------------------------------------------------------------------"
}
