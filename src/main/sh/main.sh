#!/usr/bin/env bash

source ../../../bootstrap.sh

include_lib sh-logger
include_lib sh-commons
include_file "$SRC_DIR_PATH"/functions/functions.sh

log_info "Test show some informative log text" # log_info is a reusable function inside sh-logger lib
log_warn "Test show some warning log text" # log_warn is a reusable function inside sh-logger lib

ensure_number_params_correct 1 $@

logstring "$1"

