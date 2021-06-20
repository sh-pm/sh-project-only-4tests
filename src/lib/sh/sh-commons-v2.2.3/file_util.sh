##
 # Alias to verify if path is a directory.
 #
 # @param $1: path to folder
 #
 # @return $TRUE if is folder/directory, $FALSE otherwise 
 ##
is_folder() {
  if [ -d "$1" ]; then
    # 0 = true
    return $TRUE 
  else
    # 1 = false
    return $FALSE
  fi
}



##
 # Alias to verify if file exists.
 #
 # @param $1: path to file
 #
 # @return $TRUE if exists, $FALSE otherwise 
 ##
is_existing_file() {
	if [ -e $1 ]; then
		return 0
	else  
    	return 1
	fi
}

##
 # Alias to verify if directory exists.
 #
 # @param $1: path to directory
 #
 # @return $TRUE if exists, $FALSE otherwise 
 ##
is_existing_folder() {
	if [ -d "$1" ]
	then
	    log_trace "Directory $1 exists."
    	return 0
    else
    	log_trace "Directory $1 NOT exists."  
    	return 1
	fi
}

##
 # Verify if directory is empty.
 #
 # @param $1: path to directory
 #
 # @return $TRUE if exists, $FALSE otherwise 
 ##
is_empty_folder(){
	if find "$1" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
		return $FALSE;
	else
		return $TRUE;
	fi
}
