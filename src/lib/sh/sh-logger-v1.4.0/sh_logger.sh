#!/bin/bash

source ../../../bootstrap.sh

LOG_LEVEL_FATAL="FATAL"
LOG_LEVEL_ERROR="ERROR"
LOG_LEVEL_WARN="WARN"
LOG_LEVEL_INFO="INFO"
LOG_LEVEL_DEBUG="DEBUG"
LOG_LEVEL_TRACE="TRACE"

if [[ -z "$LOG_LEVEL" ]]; then
	LOG_LEVEL=${ROOT_LOGGER_LEVEL:-$LOG_LEVEL_INFO}
fi

ESC_CHAR='\033'

RED=$ESC_CHAR'[0;31m'
GREEN=$ESC_CHAR'[0;32m'
YELLOW=$ESC_CHAR'[0;93m'
NC=$ESC_CHAR'[0m' # No Color


try_redirect_log_to_console_and_file(){
	# If was configured to log in console and file
	if [[ ! -z $SH_LOGGER_LOG_FILE ]]; then
		if [[ -f "$SH_LOGGER_LOG_FILE" ]]; then	
			exec 3>&1 1>> ${SH_LOGGER_LOG_FILE} 2>&1 # redirect stout and stderr to console and file
		fi			
	fi
}


print_msg(){
	local MSG=$1
	local LEVEL=$2
	local TIMESTAMP=`date +"%Y-%m-%d_%T.%3N"`
	
	local FILENAME=$( basename ${BASH_SOURCE[2]} )
	local LOG_LINE="$TIMESTAMP - $LEVEL - $FILENAME - ${FUNCNAME[2]} - $MSG"

	try_redirect_log_to_console_and_file
	
	if [[ "$LEVEL" == "$LOG_LEVEL_WARN" ]]; then 
		echo -e "${YELLOW}$LOG_LINE${NC}"
		return;
	fi
	if [[ "$LEVEL" == "$LOG_LEVEL_ERROR" ]]; then 
		echo -e "${RED}$LOG_LINE${NC}"
		return;
	fi
		
	echo "$LOG_LINE"
}

log_fatal(){
   if [[ $LOG_LEVEL == "$LOG_LEVEL_TRACE" || $LOG_LEVEL == "$LOG_LEVEL_DEBUG" || $LOG_LEVEL == "$LOG_LEVEL_INFO" || $LOG_LEVEL == "$LOG_LEVEL_WARN"  || $LOG_LEVEL == "$LOG_LEVEL_ERROR" || $LOG_LEVEL == "$LOG_LEVEL_FATAL" ]]; then
      print_msg "$@" $LOG_LEVEL_FATAL
   fi
}

log_error(){
   if [[ $LOG_LEVEL == "$LOG_LEVEL_TRACE" || $LOG_LEVEL == "$LOG_LEVEL_DEBUG" || $LOG_LEVEL == "$LOG_LEVEL_INFO" || $LOG_LEVEL == "$LOG_LEVEL_WARN"  || $LOG_LEVEL == "$LOG_LEVEL_ERROR" ]]; then
      print_msg "$@" $LOG_LEVEL_ERROR
   fi
}

log_warn(){
   if [[ $LOG_LEVEL == "$LOG_LEVEL_TRACE" || $LOG_LEVEL == "$LOG_LEVEL_DEBUG" || $LOG_LEVEL == "$LOG_LEVEL_INFO" || $LOG_LEVEL == "$LOG_LEVEL_WARN" ]]; then
      print_msg "$@" $LOG_LEVEL_WARN
   fi
}

log_info(){
   if [[ $LOG_LEVEL == "$LOG_LEVEL_TRACE" || $LOG_LEVEL == "$LOG_LEVEL_DEBUG" || $LOG_LEVEL == "$LOG_LEVEL_INFO" ]]; then
      print_msg "$@" $LOG_LEVEL_INFO
   fi
}

log_debug(){
   if [[ $LOG_LEVEL == "$LOG_LEVEL_TRACE" || $LOG_LEVEL == "$LOG_LEVEL_DEBUG" ]]; then
      print_msg "$@" $LOG_LEVEL_DEBUG
   fi
}

log_trace(){
   if [[ $LOG_LEVEL == "$LOG_LEVEL_TRACE" ]]; then
      print_msg "$@" $LOG_LEVEL_TRACE
   fi
}
