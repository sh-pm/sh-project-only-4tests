ensure_only_one_instance_run(){	
	local SCRIPT_NAME=$(get_script_caller_name)	
	local THIS_SCRIPT_PID=$$
	
	log_info "This script PID: $THIS_SCRIPT_PID"
	
	# list process excluding current execution 
	#  - exclude lines with PID of this process;
	#  - exclude lines with "sudo": sudo imediatelly generate other process with same name! 
	local NUMBER_OF_INSTANCES=`/bin/ps -fu $USER| grep "$SCRIPT_NAME" | grep -v "$THIS_SCRIPT_PID" | grep -v "grep" | grep -v "sudo" | awk '{print $2}'`  
	
	log_info "$NUMBER_OF_INSTANCES"
	
	if [[ $NUMBER_OF_INSTANCES > 1 ]]; then
   		log_error "$SCRIPT_NAME already in execution"
   		log_error "Current instances:"
   		#echo "/bin/ps -fu $USER| grep \"$SCRIPT_NAME\" | grep -v \"$THIS_SCRIPT_PID\" | grep -v \"grep\""
   		log_error `/bin/ps -fu $USER| grep "$SCRIPT_NAME" | grep -v "$THIS_SCRIPT_PID" | grep -v "grep"`
   		exit 1;
	fi	
}
