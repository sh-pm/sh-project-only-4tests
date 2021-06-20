#!/bin/bash
# v1.7.1 - Build with sh-pm



include_lib sh-logger

string_start_with(){
	STRING=$1
	SUBSTRING=$2
	if [[ $STRING == "$SUBSTRING"* ]]; then
		return 0;
	else
		return 1;
	fi
}

string_end_with(){
	STRING=$1
	SUBSTRING=$2
	if [[ $STRING == *"$SUBSTRING" ]]; then
		return 0;
	else
		return 1;
	fi
}

string_contains(){
	STRING=$1
	SUBSTRING=$2
	if [[ $STRING == *"$SUBSTRING"* ]]; then
		return 0;
	else
		return 1;
	fi
}

string_is_empty() {
	STRING=$1
	if [[ $STRING == "" ]]; then
		return 0;
	else
		return 1;
	fi
}

string_trim() {
	echo $1 | xargs
}

string_size() {
	STRING=$1
	echo  ${#STRING}
}