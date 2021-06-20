ensure_user_is_superuser(){
	if [ $(id -u) != "0" ]; then
    	log_error "You must be a superuser to execute this script!"
    	exit 1
	fi
}