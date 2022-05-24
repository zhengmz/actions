#!/usr/bin/env bash
#
# Copyright (c) 2022 zhengmz
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

set -e

# source functions
curl -fsSL https://github.com/zhengmz/actions/raw/lib/functions > /tmp/functions
. /tmp/functions

# echo error log and exit
error_exit() {
	error "$*"
	[[ "$ignore_error" == "true" ]] && exit 0 || exit 1
}

info "token:$token"
info "webhook:$webhook"
info "secret:$secret"
info "keyword:$keyword"
info "ignore_error:$ignore_error"
info "msgtype:$msgtype"
info "content:$content"
info "at:$at"
info "body:$body"

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

type_arr=(
text
link
markdown
actionCard
feedCard
)

if [[ -z "$body" ]]; then
	echo "${type_arr[@]}" | grep -wq "$msgtype" || error_exit "not valid msgtype [$msgtype]"
	body="{\"msgtype\": \"${msgtype}\", \"${msgtype}\": $content"
	[[ "$at" == "all" ]] && at='{"isAtAll": true}'
	[[ -n "$at" ]] && body="${body},\"at\": $at}" || body="${body}}"
fi

if [[ -n "${keyword}" ]]; then
	info "process keyword..."
	info "body:$body"
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

info "body:$body"
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

