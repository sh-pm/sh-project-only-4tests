#!/usr/bin/env bash

source ./bootstrap.sh

#-----------------------------------
evict_catastrophic_remove() {
	# Evict catastrophic rm's when ROOT_DIR_PATH not set 
	if [[ -z "$ROOT_DIR_PATH" ]]; then
		echo "bootstrap.sh file not loaded!"
		return 1
	fi
}
evict_catastrophic_remove || exit 1
#-----------------------------------

create_path_if_not_exists() {
	local PATH_TARGET
	PATH_TARGET="$1"
	
	if [[ -z "$PATH_TARGET" ]]; then
		shpm_log "${FUNCNAME[0]} run with empty param: |$PATH_TARGET|"
		return 1
	fi 

	if [[ ! -d "$PATH_TARGET" ]]; then
	   shpm_log "Creating $PATH_TARGET ..."
	   mkdir -p "$PATH_TARGET"
	fi
}

remove_folder_if_exists() {
	local PATH_TO_FOLDER
	local ACTUAL_DIR
	
	ACTUAL_DIR=$(pwd)
	PATH_TO_FOLDER="$1"
	
	if [[ -z "$PATH_TO_FOLDER" ]]; then
		shpm_log "${FUNCNAME[0]} run with empty param: |$PATH_TO_FOLDER|"
		return "$FALSE"
	fi 
	
	if [[ -d "$PATH_TO_FOLDER" ]]; then
		shpm_log "Removing folder $PATH_TO_FOLDER ..."
	
		# SECURE rm -rf: move content to TMP_DIR, and execute rm -rf only inside TMP_DIR
		mv "$PATH_TO_FOLDER" "$TMP_DIR_PATH"
		
		cd "$TMP_DIR_PATH" || exit
		
		rm -rf "$(basename "$PATH_TO_FOLDER")"
		
		cd "$ACTUAL_DIR" || exit
		
		return "$TRUE"
	else
	    return "$FALSE"	
	fi
}

remove_file_if_exists() {
	local PATH_TO_FILE
	local ACTUAL_DIR
	
	ACTUAL_DIR=$(pwd)
	PATH_TO_FILE="$1"
	
	if [[ -z "$PATH_TO_FILE" ]]; then
		shpm_log "${FUNCNAME[0]} run with empty param: |$PATH_TO_FILE|"
		return 1
	fi 
	
	if [[ -f "$PATH_TO_FILE" ]]; then
		shpm_log "Removing file $PATH_TO_FILE ..."
	
		# SECURE rm -rf: move content to TMP_DIR, and execute rm -rf only inside TMP_DIR
		mv "$PATH_TO_FILE" "$TMP_DIR_PATH"
		
		cd "$TMP_DIR_PATH" || exit
		
		rm -f "$(basename "$PATH_TO_FILE")"
		
		cd "$ACTUAL_DIR" || exit
			
		return "$TRUE"
	else
	    return "$FALSE"	
	fi
}

shpm_log() {
	echo "$1"
}

shpm_log_operation() {
    echo "================================================================"
	echo "sh-pm: $1"
	echo "================================================================"
}

print_help() {
  
    SCRIPT_NAME=shpm

    echo "SH-PM: Shell Script Package Manager"
	echo ""
	echo "USAGE:"
	echo "  [$SCRIPT_NAME] [OPTION]"
	echo ""
	echo "OPTIONS:"
    echo "  update                Download dependencies in local repository $LIB_DIR_SUBPATH"
	echo "  clean                 Clean $TARGET_DIR_PATH folder"
    echo "  test                  Run shellcheck (if exists) and tests in $TEST_DIR_SUBPATH folder"
    echo "  build                 Create compressed file in $TARGET_DIR_PATH folder"
	echo "  install               Install in local repository $LIB_DIR_SUBPATH"            
    echo "  publish               Publish code and builded file in GitHub repositories (remote and local)"
	echo "  init                  Initialize sh-pm expect files and folders project structure" 
    echo "  autoupdate            Update itself"
	echo "  uninstall             Remove from local repository $LIB_DIR_SUBPATH"
	echo ""
	echo "EXAMPLES:"
	echo "  ./shpm update"
	echo ""
	echo "  ./shpm init"
	echo ""
	echo "  ./shpm build"
	echo ""
	echo "  ./shpm publish"
	echo ""
}

run_sh_pm() {
	local GIT_CMD

	local UPDATE=false
	local TEST=false
	local CLEAN=false
	local BUILD=false
	local INSTALL=false	
	local PUBLISH=false
	local SKIP_SHELLCHECK=false
	local AUTOUPDATE=false
	local UNINSTALL=false
	local INIT=false	
	
	local VERBOSE=false	
	
	GIT_CMD=$(which git)
	
	if [ $# -eq 0 ];  then
		print_help
		exit 1
	else
		for (( i=1; i <= $#; i++)); do	
	        ARG="${!i}"
	
			if [[ "$ARG" == "update" ]];  then
				UPDATE="true"
			fi

			if [[ "$ARG" == "test" ]];  then
				TEST="true"
			fi
			
			if [[ "$ARG" == "clean" ]];  then
				CLEAN="true"
			fi
		
			if [[ "$ARG" == "build" ]];  then
				BUILD="true"
				i=$((i+1))
				SKIP_SHELLCHECK="${!i:-false}"
			fi
			
			if [[ "$ARG" == "install" ]];  then
				INSTALL="true"
			fi
			
			if [[ "$ARG" == "publish" ]];  then
				PUBLISH="true"
				i=$((i+1))
				SKIP_SHELLCHECK="${!i:-false}"
			fi
			
			if [[ "$ARG" == "autoupdate" ]];  then
				AUTOUPDATE="true"
			fi
			
			if [[ "$ARG" == "uninstall" ]];  then
				UNINSTALL="true"
			fi
			if [[ "$ARG" == "init" ]];  then
				INIT="true"
			fi
			if [[ "$ARG" == "-v" ]];  then
				VERBOSE="true"
			fi
		done
	fi
	
	if [[ "$UPDATE" == "true" ]];  then
		update_dependencies	"$VERBOSE"
	fi
	
	if [[ "$CLEAN" == "true" ]];  then
		clean_release
	fi
	
	if [[ "$TEST" == "true" ]];  then
		run_all_tests
	fi
	
	if [[ "$BUILD" == "true" ]];  then
		build_release
	fi
	
	if [[ "$INSTALL" == "true" ]];  then
		install_release
	fi
	
	if [[ "$PUBLISH" == "true" ]];  then	
		publish_release "$VERBOSE"
	fi
	
	if [[ "$AUTOUPDATE" == "true" ]];  then	
		auto_update
	fi
	
	if [[ "$UNINSTALL" == "true" ]];  then
		uninstall_release
	fi
		
	if [[ "$INIT" == "true" ]];  then
		init_project_structure
	fi			
}

remove_tar_gz_from_folder() {
	local ACTUAL_DIR
	local FOLDER
	
	ACTUAL_DIR=$(pwd)
	FOLDER="$1"
	
	if [[ ! -z "$FOLDER" && -d "$FOLDER" ]]; then
	
		shpm_log "Removing *.tar.gz files from $FOLDER ..."
		
		cd "$FOLDER" || exit 1
		rm ./*.tar.gz 2> /dev/null
		
		shpm_log "Done"		
	else
		shpm_log "ERROR: $FOLDER not found."
		return "$FALSE" 
	fi
	
	cd "$ACTUAL_DIR" || exit
	
	return "$TRUE"
}

clean_release() {
	local ACTUAL_DIR
	local RELEASES_DIR
	
	ACTUAL_DIR=$(pwd)
	RELEASES_DIR="$ROOT_DIR_PATH/releases"

	shpm_log_operation "Cleaning release"
	
	remove_tar_gz_from_folder "$TARGET_DIR_PATH"
	
	remove_tar_gz_from_folder "$RELEASES_DIR"
		
	cd "$ACTUAL_DIR" || exit
}

update_dependencies() {
	shpm_log_operation "Update Dependencies"
	
    local VERBOSE="$1"
	
	shpm_log "Start update of ${#DEPENDENCIES[@]} dependencies ..."
	for DEP_ARTIFACT_ID in "${!DEPENDENCIES[@]}"; do 
		update_dependency "$DEP_ARTIFACT_ID" "$VERBOSE"
	done
	
	cd "$ROOT_DIR_PATH" || exit 1
	
	shpm_log "Done"
}

uninstall_release () {
	shpm_log_operation "Uninstall lib"
	
	local TARGET_FOLDER
	local TGZ_FILE
	local TGZ_FILE_PATH
	
	local ACTUAL_DIR

	TARGET_FOLDER="$ARTIFACT_ID""-""$VERSION"
	TGZ_FILE="$TARGET_FOLDER"".tar.gz"
	TGZ_FILE_PATH="$TARGET_DIR_PATH/$TGZ_FILE"
	
	ACTUAL_DIR="$(pwd)"
	
	clean_release
	
	build_release
	
	remove_tar_gz_from_folder "$LIB_DIR_PATH"
	
	remove_folder_if_exists "$LIB_DIR_PATH/$TARGET_FOLDER"
	
	cd "$ACTUAL_DIR" || exit
	
	shpm_log "Done"
}

install_release () {
	local TARGET_FOLDER
	local TGZ_FILE
	local TGZ_FILE_PATH
	
	local ACTUAL_DIR

	TARGET_FOLDER="$ARTIFACT_ID""-""$VERSION"
	TGZ_FILE="$TARGET_FOLDER"".tar.gz"
	TGZ_FILE_PATH="$TARGET_DIR_PATH/$TGZ_FILE"

	ACTUAL_DIR=$(pwd)
	
	build_release
	
	uninstall_release
	
	shpm_log_operation "Install Release into local repository"
	
	shpm_log "Install $TGZ_FILE_PATH into $LIB_DIR_PATH ..."
	cd "$LIB_DIR_PATH/" || exit
	
	cp "$TGZ_FILE_PATH" "$LIB_DIR_PATH/"	
	
	tar -xzf "$TGZ_FILE"
		
	remove_file_if_exists "$TGZ_FILE_PATH"
	
	cd "$ACTUAL_DIR" || exit
	
	shpm_log "Done"
}

git_clone() {
	local GIT_CMD
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY=$1
	DEP_ARTIFACT_ID=$2
	DEP_VERSION=$3
	
	GIT_CMD="$(which git)"

	if "$GIT_CMD" clone --branch "$DEP_VERSION" "https://""$REPOSITORY""/""$DEP_ARTIFACT_ID"".git" &>/dev/null ; then
		return $TRUE
	fi
	return $FALSE
}

download_from_git_to_tmp_folder() {
	local GIT_CMD
	local REPOSITORY
	local DEP_ARTIFACT_ID
	local DEP_VERSION
	
	REPOSITORY=$1
	DEP_ARTIFACT_ID=$2
	DEP_VERSION=$3

	remove_folder_if_exists "$TMP_DIR_PATH/$DEP_ARTIFACT_ID"
	
	cd "$TMP_DIR_PATH" || exit
	
	shpm_log "     - Cloning from https://$REPOSITORY/$DEP_ARTIFACT_ID into /tmp/$DEP_ARTIFACT_ID ..."
	shpm_log "        $GIT_CMD clone --branch $DEP_VERSION https://$REPOSITORY/$DEP_ARTIFACT_ID.git"
	
	if git_clone "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION" &>/dev/null ; then
		return $TRUE
	fi
	return $FALSE

}

shpm_update_itself_after_git_clone() {
    shpm_log "     WARN: sh-pm updating itself ..."
    
    local PATH_TO_DEP_IN_TMP
    local PATH_TO_DEP_IN_PROJECT
    
    PATH_TO_DEP_IN_TMP="$1"
    PATH_TO_DEP_IN_PROJECT="$2"
    
    shpm_log "     - Copy $BOOTSTRAP_FILENAME to $PATH_TO_DEP_IN_PROJECT ..."
	cp "$PATH_TO_DEP_IN_TMP/$BOOTSTRAP_FILENAME" "$PATH_TO_DEP_IN_PROJECT"
			
	shpm_log "     - Update $BOOTSTRAP_FILENAME sourcing command from shpm.sh file ..."
	sed -i 's/source \.\.\/\.\.\/\.\.\/bootstrap.sh/source \.\/bootstrap.sh/g' "$PATH_TO_DEP_IN_PROJECT/shpm.sh"
    
    if [[ -f "$ROOT_DIR_PATH/shpm.sh" ]]; then
    	create_path_if_not_exists "$ROOT_DIR_PATH/tmpoldshpm"
    	
    	shpm_log "   - backup actual sh-pm version to $ROOT_DIR_PATH/tmpoldshpm ..."
    	mv "$ROOT_DIR_PATH/shpm.sh" "$ROOT_DIR_PATH/tmpoldshpm"
    fi
    
    if [[ -f "$PATH_TO_DEP_IN_PROJECT/shpm.sh" ]]; then
    	shpm_log "   - update shpm.sh ..."
    	cp "$PATH_TO_DEP_IN_PROJECT/shpm.sh"	"$ROOT_DIR_PATH"
    fi
    
    if [[ -f "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME" ]]; then
    	shpm_log "   - backup actual $BOOTSTRAP_FILENAME to $ROOT_DIR_PATH/tmpoldshpm ..."
    	mv "$ROOT_DIR_PATH/$BOOTSTRAP_FILENAME" "$ROOT_DIR_PATH/tmpoldshpm"
    fi
    
    if [[ -f "$PATH_TO_DEP_IN_PROJECT/$BOOTSTRAP_FILENAME" ]]; then
    	shpm_log "   - update $BOOTSTRAP_FILENAME ..."
    	cp "$PATH_TO_DEP_IN_PROJECT/$BOOTSTRAP_FILENAME"	"$ROOT_DIR_PATH"
    fi
}

set_dependency_repository(){
	local DEP_ARTIFACT_ID="$1"
	local R_DEP_REPOSITORY
	
	local ARTIFACT_DATA="${DEPENDENCIES[$DEP_ARTIFACT_ID]}"
	if [[ "$ARTIFACT_DATA" == *"@"* ]]; then
		R_DEP_REPOSITORY=$( echo "$ARTIFACT_DATA" | cut -d "@" -f 2 | xargs ) #xargs is to trim string!
		
		if [[ "$R_DEP_REPOSITORY" == "" ]]; then
			shpm_log "Error in $DEP_ARTIFACT_ID dependency: Inform a repository after '@' in $DEPENDENCIES_FILENAME"
			exit 1
		fi
	else
		shpm_log "Error in $DEP_ARTIFACT_ID dependency: Inform a repository after '@' in $DEPENDENCIES_FILENAME"
		exit 1
	fi
	
	eval "$2=$R_DEP_REPOSITORY"
}

set_dependency_version(){
	local DEP_ARTIFACT_ID="$1"
	local R_DEP_VERSION	
	
	local ARTIFACT_DATA="${DEPENDENCIES[$DEP_ARTIFACT_ID]}"
	if [[ "$ARTIFACT_DATA" == *"@"* ]]; then
		R_DEP_VERSION=$( echo "$ARTIFACT_DATA" | cut -d "@" -f 1 | xargs ) #xargs is to trim string!						
	else
		shpm_log "Error in $DEP_ARTIFACT_ID dependency: Inform a repository after '@' in $DEPENDENCIES_FILENAME"
		exit 1
	fi
	
	eval "$2=$R_DEP_VERSION"
}

update_dependency() {
    local DEP_ARTIFACT_ID=$1
    local VERBOSE=$2
    
	local DEP_VERSION
	local REPOSITORY
	local DEP_FOLDER_NAME
	local PATH_TO_DEP_IN_PROJECT
	local PATH_TO_DEP_IN_TMP
	
	local ACTUAL_DIR
	
	ACTUAL_DIR=$( pwd )
	
	create_path_if_not_exists "$LIB_DIR_PATH" 
	
	set_dependency_repository "$DEP_ARTIFACT_ID" REPOSITORY 
	set_dependency_version "$DEP_ARTIFACT_ID" DEP_VERSION

	DEP_FOLDER_NAME="$DEP_ARTIFACT_ID""-""$DEP_VERSION"
	PATH_TO_DEP_IN_PROJECT="$LIB_DIR_PATH/$DEP_FOLDER_NAME"
	PATH_TO_DEP_IN_TMP="$TMP_DIR_PATH/$DEP_ARTIFACT_ID"
	
	shpm_log "----------------------------------------------------"
	shpm_log "  Updating $DEP_ARTIFACT_ID to $DEP_VERSION: Start"				
	 
	if download_from_git_to_tmp_folder "$REPOSITORY" "$DEP_ARTIFACT_ID" "$DEP_VERSION" &>/dev/null ; then
	
		remove_folder_if_exists "$PATH_TO_DEP_IN_PROJECT"		
		create_path_if_not_exists "$PATH_TO_DEP_IN_PROJECT"
					
		shpm_log "   - Copy artifacts from $PATH_TO_DEP_IN_TMP to $PATH_TO_DEP_IN_PROJECT ..."
		cp "$PATH_TO_DEP_IN_TMP/src/main/sh/"* "$PATH_TO_DEP_IN_PROJECT"
		cp "$PATH_TO_DEP_IN_TMP/pom.sh" "$PATH_TO_DEP_IN_PROJECT"
		
		# if update a sh-pm
		if [[ "$DEP_ARTIFACT_ID" == "sh-pm" ]]; then
			shpm_update_itself_after_git_clone "$PATH_TO_DEP_IN_TMP" "$PATH_TO_DEP_IN_PROJECT"
		fi
		
		shpm_log "   - Removing $PATH_TO_DEP_IN_TMP ..."
		remove_folder_if_exists "$PATH_TO_DEP_IN_TMP"
		
		cd "$ACTUAL_DIR" || exit
	
	else 		   		  
       shpm_log "  $DEP_ARTIFACT_ID was not updated to $DEP_VERSION!"
	fi
	
	shpm_log "  Update $DEP_ARTIFACT_ID to $DEP_VERSION: Finish"
	
	cd "$ACTUAL_DIR" || exit 1
}

build_release() {

    clean_release

	run_all_tests
	
	# Verify if are unit test failures
	if [ ! -z "${TEST_STATUS+x}" ]; then
		if [[ "$TEST_STATUS" != "OK" ]]; then
			shpm_log "Unit Test's failed!"
			exit 1; 
		fi
	fi

	shpm_log_operation "Build Release"

	local HOST="${REPOSITORY[host]}"
	local PORT="${REPOSITORY[port]}"	

	shpm_log "Remove $TARGET_DIR_PATH folder ..."
	remove_folder_if_exists "$TARGET_DIR_PATH"
	
	TARGET_FOLDER="$ARTIFACT_ID""-""$VERSION"
	
	echo "$TARGET_DIR_PATH/$TARGET_FOLDER"
	create_path_if_not_exists "$TARGET_DIR_PATH/$TARGET_FOLDER"

	shpm_log "Coping .sh files from $SRC_DIR_PATH/* to $TARGET_DIR_PATH/$TARGET_FOLDER ..."
	cp -R "$SRC_DIR_PATH"/* "$TARGET_DIR_PATH/$TARGET_FOLDER"
	
	# if not build itself
	if [[ ! -f "$SRC_DIR_PATH/shpm.sh" ]]; then
		shpm_log "Coping pom.sh ..."
		cp "$ROOT_DIR_PATH/pom.sh" "$TARGET_DIR_PATH/$TARGET_FOLDER"
	else 
		shpm_log "Creating pom.sh ..."
	    cp "$SRC_DIR_PATH/../resources/template_pom.sh" "$TARGET_DIR_PATH/$TARGET_FOLDER/pom.sh"
	    
	    shpm_log "Coping bootstrap.sh ..."
    	cp "$ROOT_DIR_PATH/bootstrap.sh" "$TARGET_DIR_PATH/$TARGET_FOLDER"
	fi
	
	shpm_log "Add sh-pm comments in .sh files ..."
	cd "$TARGET_DIR_PATH/$TARGET_FOLDER" || exit
	sed -i 's/\#\!\/bin\/bash/\#\!\/bin\/bash\n# '"$VERSION"' - Build with sh-pm/g' ./*.sh
		
	# if not build itself
	if [[ ! -f $TARGET_DIR_PATH/$TARGET_FOLDER/"shpm.sh" ]]; then
		shpm_log "Removing bootstrap.sh sourcing command from .sh files ..."
		sed -i 's/source \.\/bootstrap.sh//g' ./*.sh		
		sed -i 's/source \.\.\/\.\.\/\.\.\/bootstrap.sh//g' ./*.sh
	else
		shpm_log "Update bootstrap.sh sourcing command from .sh files ..."
	   	sed -i 's/source \.\.\/\.\.\/\.\.\/bootstrap.sh/source \.\/bootstrap.sh/g' shpm.sh	   	
	fi
	
	shpm_log "Package: Compacting .sh files ..."
	cd "$TARGET_DIR_PATH" || exit
	tar -czf "$TARGET_FOLDER"".tar.gz" "$TARGET_FOLDER"
	
	if [[ -d "$TARGET_DIR_PATH/$TARGET_FOLDER" ]]; then
		rm -rf "${TARGET_DIR_PATH:?}/${TARGET_FOLDER:?}"
	fi
	
	shpm_log "Relese file generated in folder $TARGET_DIR_PATH"
	
	cd "$ROOT_DIR_PATH" || exit
	
	shpm_log "Done"
}


create_new_remote_branch_from_master_branch() {
	local ACTUAL_BRANCH
	local MASTER_BRANCH
	local NEW_BRANCH
	local GIT_CMD

	NEW_BRANCH="$1"
	
	if [[ "$NEW_BRANCH" != "" ]]; then
		GIT_CMD=$( which git )
		
		cd "$ROOT_DIR_PATH" || exit 1;
	
		$GIT_CMD add .
	
		$GIT_CMD commit -m "$NEW_BRANCH" -m "- New release version"
		
		ACTUAL_BRANCH=$( $GIT_CMD rev-parse --abbrev-ref HEAD | xargs )

		if [[ "$ACTUAL_BRANCH" != "master" && "$ACTUAL_BRANCH" != "main" ]]; then
			MASTER_BRANCH=$( $GIT_CMD branch | grep "master\|main" | xargs )
			$GIT_CMD checkout "$MASTER_BRANCH" 
		fi
		
		$GIT_CMD push origin "$MASTER_BRANCH"

		$GIT_CMD checkout -b "$NEW_BRANCH"

		$GIT_CMD push -u origin "$NEW_BRANCH"
	fi
}

publish_release() {

	local VERBOSE=$1

	clean_release
	
	build_release

	shpm_log_operation "Starting publish release process"
	
	local TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	local TGZ_FILE_NAME=$TARGET_FOLDER".tar.gz"
	local FILE_PATH=$TARGET_DIR_PATH/$TGZ_FILE_NAME
	
	shpm_log_operation "Copying .tgz file to releaes folder"
	local RELEASES_PATH

	RELEASES_PATH="$ROOT_DIR_PATH""/""releases"

	if [[ ! -d "$RELEASES_PATH" ]]; then
		mkdir -p "$RELEASES_PATH"
	fi

	cp "$FILE_PATH" "$RELEASES_PATH" 
	
	create_new_remote_branch_from_master_branch "$VERSION" 
}

send_to_sh_archiva () {
	local VERBOSE=$1

	if [[ "$SSO_API_AUTHENTICATION_URL" == "" ]]; then
		shpm_log "In order to publish release, you must define SSO_API_AUTHENTICATION_URL variable in your pom.sh."
		exit 1
	fi

	clean_release
	
	build_release

	shpm_log_operation "Starting publish release process"
	
	local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	

	local TARGET_FOLDER=$ARTIFACT_ID"-"$VERSION
	local TGZ_FILE_NAME=$TARGET_FOLDER".tar.gz"
	local FILE_PATH=$TARGET_DIR_PATH/$TGZ_FILE_NAME


	local TARGET_REPO="https://$HOST:$PORT/sh-archiva/snapshot/$GROUP_ID/$ARTIFACT_ID/$VERSION"
	shpm_log "----------------------------------------------------------------------------"
	shpm_log "From: $FILE_PATH"
	shpm_log "  To: $TARGET_REPO"
	shpm_log "----------------------------------------------------------------------------"
	
	echo Username:
	read -r USERNAME
	
	echo Password:
	read -r -s PASSWORD
	
	shpm_log "Authenticating user \"$USERNAME\" in $SSO_API_AUTHENTICATION_URL ..."
	#echo "curl -s -X POST -d '{"username" : "'"$USERNAME"'", "password": "'"$PASSWORD"'"}' -H 'Content-Type: application/json' "$SSO_API_AUTHENTICATION_URL""	
	TOKEN=$( curl -s -X POST -d '{"username" : "'"$USERNAME"'", "password": "'"$PASSWORD"'"}' -H 'Content-Type: application/json' "$SSO_API_AUTHENTICATION_URL" )
	
	if [[ "$TOKEN" == "" ]]; then
		shpm_log "Authentication failed"
		exit 2
	else
		shpm_log "Authentication successfull"
		shpm_log "Sending release to repository $TARGET_REPO  ..."
		TOKEN_HEADER="Authorization: Bearer $TOKEN"
		
		CURL_OPTIONS="-s"
		if [[ "$VERBOSE" == "true" ]]; then
		    CURL_OPTIONS="-v"
		fi
			
		MSG_RETURNED=$( curl "$CURL_OPTIONS" -F file=@"$FILE_PATH" -H "$TOKEN_HEADER" "$TARGET_REPO" )
		shpm_log "Sended"
		
		shpm_log "Return received from repository:"
		shpm_log "----------------------------------------------------------------------------"
		shpm_log "$MSG_RETURNED"
		shpm_log "----------------------------------------------------------------------------"
		
		shpm_log "Done"
	fi 

}

run_shellcheck() {
    local SHELLCHECK_CMD
    local SHELLCHECK_LOG_FILENAME
    local GEDIT_CMD
    
    SHELLCHECK_CMD=$(which shellcheck)
    SHELLCHECK_LOG_FILENAME="shellcheck.log"
    
    GEDIT_CMD=$(which gedit)

	shpm_log_operation "Running ShellCheck in .sh files ..."
    
    if [[ "$SKIP_SHELLCHECK" == "true" ]]; then
    	shpm_log ""
    	shpm_log "WARNING: Skipping ShellCheck verification !!!"
    	shpm_log ""
    	return "$TRUE" # continue execution with warning    	
    fi
    
    if [[ ! -z "$SHELLCHECK_CMD" ]]; then
	    
	    create_path_if_not_exists "$TARGET_DIR_PATH"
	    
	    for FILE_TO_CHECK in $SRC_DIR_PATH/*.sh; do        
	    
	    	if "$SHELLCHECK_CMD" -x -e SC1090 -e SC1091 "$FILE_TO_CHECK" > "$TARGET_DIR_PATH/$SHELLCHECK_LOG_FILENAME"; then	    	
	    		shpm_log "$FILE_TO_CHECK passed in shellcheck"
	    	else
	    		shpm_log "$FILE_TO_CHECK have shellcheck errors."
	    		shpm_log "See log in $TARGET_DIR_PATH/$SHELLCHECK_LOG_FILENAME"
	    		
	    		sed -i '1s/^/=== ERRORS FOUND BY ShellCheck tool: === /' "$TARGET_DIR_PATH/$SHELLCHECK_LOG_FILENAME"
	    		
	    		if [[ "$GEDIT_CMD" != "" ]]; then
	    			shpm_log "Open $TARGET_DIR_PATH/$SHELLCHECK_LOG_FILENAME ..."
	    			"$GEDIT_CMD" "$TARGET_DIR_PATH/$SHELLCHECK_LOG_FILENAME"
	    		fi
	    		
	    		exit 1
	    	fi
    	done;
    else
    	shpm_log "WARNING: ShellCheck not found: skipping ShellCheck verification !!!"
    fi
    
    shpm_log ""
    shpm_log "ShellCheck finish."
    shpm_log ""
}

run_all_tests() {

	run_shellcheck

	shpm_log_operation "Searching unit test files to run ..."

	local ACTUAL_DIR
	ACTUAL_DIR=$(pwd)

	if [[ -d "$TEST_DIR_PATH" ]]; then
	
		cd "$TEST_DIR_PATH" || exit
		
		local TEST_FILES
		TEST_FILES=( $(ls ./*_test.sh 2> /dev/null) );
		
		shpm_log "Found ${#TEST_FILES[@]} test files" 
		if (( "${#TEST_FILES[@]}" > 0 )); then
			for file in "${TEST_FILES[@]}"
			do
				shpm_log "Run file ..."
				source "$file"
			done
		else
			shpm_log "Nothing to test"
		fi
	
	else 
		shpm_log "Nothing to test"
	fi
	
	cd "$ACTUAL_DIR" || exit 1
	shpm_log "Done"
}

auto_update() {

	shpm_log_operation "Running sh-pm auto update ..."
	 
    local HOST=${REPOSITORY[host]}
	local PORT=${REPOSITORY[port]}	
	
	for DEP_ARTIFACT_ID in "${!DEPENDENCIES[@]}"; do 
	    if [[ "$DEP_ARTIFACT_ID" == "sh-pm" ]]; then		
			update_dependency "$DEP_ARTIFACT_ID"
			
			shpm_log "Done"
	        exit 0    
	    fi
	done
	
	shpm_log "Could not update sh-pm: sh-pm not present in dependencies of pom.sh"
	exit 1004
}

init_project_structure() {

	shpm_log_operation "Running sh-pm init ..."
	
	local FILENAME
	FILENAME="/tmp/nothing"
	
	create_path_if_not_exists "$SRC_DIR_PATH"

	create_path_if_not_exists "$TEST_DIR_PATH"
	    
    cd "$ROOT_DIR_PATH" || exit 1
    
    shpm_log "Move source code to $SRC_DIR_PATH ..."
    for file in "$ROOT_DIR_PATH"/*
	do
        FILENAME=$( basename "$file" )
        
        if [[  "$FILENAME" != "."* && "$FILENAME" != *"*"* && "$FILENAME" != *"~"* && "$FILENAME" != *"\$"* ]]; then
		    if [[ -f $file ]]; then
		        if [[ "$FILENAME" != "bootstrap.sh" && "$FILENAME" != "pom.sh" && "$FILENAME" != "shpm.sh" && "$FILENAME" == *".sh" ]]; then
		            shpm_log " - Moving file $file to $SRC_DIR_PATH ..."
		            mv "$file" "$SRC_DIR_PATH"
		        else
		        	shpm_log " - Skipping $file"
		        fi
		    fi
		    if [[ -d $file ]]; then
		        if [[ "$FILENAME" != "src" && "$FILENAME" != "target" && "$FILENAME" != "tmpoldshpm" ]]; then
	   	            shpm_log " - Moving folder $file to $SRC_DIR_PATH ..."
	   	            mv "$file" "$SRC_DIR_PATH"
	   	        else
	   	        	shpm_log " - Skipping $file"	            
		        fi
		    fi
		else
		    shpm_log " - Skipping $file"
	    fi
	done
	
	cd "$SRC_DIR_PATH" || exit 1 
	
	shpm_log "sh-pm expected project structure initialized"
	exit 0
}



run_sh_pm "$@"
