#!/usr/bin/env bash
#
# Copyright (c) 2022 zhengmz
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

set -e

# source functions
lib_file="functions"
if [ ! -f "$lib_file" ]; then
	echo "get functions from web..."
	curl -fsSL https://github.com/zhengmz/actions/raw/lib/functions > $lib_file
fi
. $lib_file

# echo error log and exit
error_exit() {
	error "$*"
	[[ "$ignore_error" == "true" ]] && exit 0 || exit 1
}

if [[ -z "$token" && -z "$webhook" ]]; then
	error_exit "token or webhook is required"
fi

url="https://oapi.dingtalk.com/robot/send?access_token=${token}"
[[ -n "${webhook}" ]] && url="${webhook}"

if [[ -n "$secret" ]]; then
	timestamp=$(echo $[$(date +%s%N)/1000000])
	sign="${timestamp}\n${secret}"
	sign=$(echo -en "$sign" | openssl dgst -sha256 -hmac "$secret" -binary)
	sign=$(echo -n "$sign"|base64)
	url="${url}&timestamp=${timestamp}&sign=${sign}"
fi

if [[ -z "$body" && -z "$content" ]]; then
	error_exit "body or content is required"
fi

msgtype_arr=(
text
link
markdown
actionCard
feedCard
)

if [[ -z "$body" ]]; then
	echo "${msgtype_arr[@]}" | grep -wq "$msgtype" || error_exit "not valid msgtype [$msgtype]"
	body="{\"msgtype\": \"${msgtype}\", \"${msgtype}\": $content"
	[[ "$at" == "all" ]] && at='{"isAtAll": true}'
	[[ -n "$at" ]] && body="${body},\"at\": $at}" || body="${body}}"
fi

if [[ -n "${keyword}" ]]; then
	info "add keyword to title or content..."
	msgtype=$(echo "$body" | jq -r .msgtype)
	key=".${msgtype}.title"
	case $msgtype in
		text)
			key=".text.content"
			;;
		feedCard)
			key=".feedCard.links[0].title"
			;;
	esac
	value=$(echo "$body" | jq -r "${key}")
	body=$(echo "$body" | jq "${key}=\"$value \n keyword: $keyword\"")
fi

info "Sending message to DingTalk..."

errmsg=$(curl -sSX POST "${url}" \
	-H 'Content-Type: application/json' \
	-d "$body")

errcode=$(echo ${errmsg} | jq -r .errcode)
if [[ "${errcode}" != "0" ]]; then
	error_exit "DingTalk message sending failed: ${errmsg}"
else
	info "DingTalk message sent successfully!"
fi

