#!/bin/bash
# v1.7.1 - Build with sh-pm



include_lib sh-logger


set_local_ip() {
	log_info "Try get Local IP ..."
	COMMON_INTERFACES=("eth0" "wlan0")
	
	local IP=''
	
	for INTERFACE in "${COMMON_INTERFACES[@]}"
	do
        log_debug "Try interface: $INTERFACE"

		log_debug "Try mode (1)"
        IP=$(/sbin/ifconfig $INTERFACE | grep 'inet addr:' | cut -d':' -f2 | awk '{print $1}')
        log_trace "IP: |$IP|"
        if [[ "$IP" != "" ]]; then
            break
        fi

		log_debug "Try mode (2)"
        IP=$(/sbin/ifconfig $INTERFACE | grep 'inet ' | awk '{print $2}')
        log_trace "IP: |$IP|"
        if [[ "$IP" != "" ]]; then
            break
        fi
	done;
	
	eval "$1=$IP"
}


set_host_ip() {

	log_info "Get local IP ..."
	IP_LOCAL=$( curl --max-time $CURL_TIMEOUT https://ifconfig.me 2>/dev/null )
	
	if [[ "$IP_LOCAL" == "" || "$1" == "localhost" ]]; then
	        log_warn "Unable to get IP using https://ifconfig.me"
	        IP_LOCAL="127.0.0.1"
	fi
	log_info "IP $IP_LOCAL will be used"
	
	eval "$1=$IP_LOCAL"
}
