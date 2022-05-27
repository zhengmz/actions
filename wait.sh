#!/usr/bin/env bash
#
# Copyright (c) 2022 zhengmz
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

set -e

# source functions
lib_file="/tmp/functions"
if [ ! -f "$lib_file" ]; then
	echo "get functions from web..."
	curl -fsSL https://github.com/zhengmz/actions/raw/lib/functions > $lib_file
fi
. $lib_file

PRT_INTERVAL=${PRT_INTERVAL:-10}
PRT_MSG="
-----------------------------------------------------------------------------------
To connect to this session copy and paste the following into a terminal or browser:
⚡ CLI: $(green ${TMATE_SSH})
🔗 URL: ${TMATE_WEB}
🔔 TIPS: Run 'touch ${KEEP_FILE}' to keepalive or 'exit' to next step
-----------------------------------------------------------------------------------
"
i=1
# Wait for connection to close or timeout in 30 min (default)
timeout=${1:-30}
timeout=$((timeout*60))
info "Timeout seconds is $timeout..."
while [[ -S ${TMATE_SOCK} ]]; do
    sleep 1

    timeout=$(($timeout-1))
    if [ ! -f ${KEEP_FILE} ]; then
        if (( timeout < 0 )); then
            warn "Waiting on tmate connection timed out!"
	    break
        fi

        i=$((i+1))
        if [[ $i -gt ${PRT_INTERVAL} ]]; then
            echo -e "${PRT_MSG}"
            i=1
        fi
    fi
done

ps -ef|grep tmate|grep -v grep
# The next step receive: The runner has received a shutdown signal.
# So kill session explicitly to release tmate connect
[[ -S ${TMATE_SOCK} ]] && tmate -S ${TMATE_SOCK} kill-session
echo "After kill session..."
ps -ef|grep tmate|grep -v grep
exit 0

