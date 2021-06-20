#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-logger
include_lib sh-commons

logstring() {
   ensure_number_params_correct 1 $@
   log_info "Content of param received: $1"
}

