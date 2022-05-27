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

TMATE_SOCK="/tmp/tmate.sock"

# Install tmate on macOS or Ubuntu
info "Setting up tmate ..."
if [ ! -x "$(command -v tmate)" ]; then
	if [ -x "$(command -v brew)" ]; then
	    brew install tmate
	elif [ -x "$(command -v apt-get)" ]; then
	    sudo apt-get install -y tmate
	else
	    error "This system is not supported!"
	    exit 1
	fi
fi

# Generate ssh key if needed
[[ -e ~/.ssh/id_rsa ]] || ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

# Run deamonized tmate
info "Running tmate..."
tmate -S ${TMATE_SOCK} new-session -d
tmate -S ${TMATE_SOCK} wait tmate-ready

# Print connection info
TMATE_SSH=$(tmate -S ${TMATE_SOCK} display -p '#{tmate_ssh}')
TMATE_WEB=$(tmate -S ${TMATE_SOCK} display -p '#{tmate_web}')

echo "::set-output name=TMATE_SOCK::$TMATE_SOCK"
echo "::set-output name=TMATE_SSH::$TMATE_SSH"
echo "::set-output name=TMATE_WEB::$TMATE_WEB"

