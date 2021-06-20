is_number() {
	local VALUE=$1
	local REGEX='^[+-]?[0-9]+([.][0-9]+)?$'
	
	if ! [[ $VALUE =~ $REGEX ]] ; then
   		return $FALSE;
	fi
	
	return $TRUE;
}

ensure_is_number() {
	if ! is_number $1; then
    	log_error "$1 is not a number!"
    	exit 1
	fi
}