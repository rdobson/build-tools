#!/bin/bash
set -eux

if [ "$#" -le 4 ]; then
    echo "Invalid parameters"
    echo "Usage: $0 vmuuid password script xenserver_host xenserver_password"
    exit 1
fi

. ./functions.sh

VMUUID=$1
PASSWORD=$2
XENSERVER_HOST=$3
XENSERVER_PASSWORD=$4
SCRIPT=$5

XENSERVER_USERNAME="root"

ip=""
while [[ $ip == "" ]]; do
    sleep 1
    ip=$(xecommand vm-param-get uuid="$VMUUID" param-name=networks | sed -ne 's,^.*0/ip: \([0-9.]*\).*$,\1,p')
    if [[ $ip != "" ]]; then
        if [[ $(sshcommand "echo ok") != "ok" ]]; then
            ip=""
        fi
    fi
done

tmpdir=$(sshcommand mktemp -d)
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no -r ./ root@"$ip":"$tmpdir"
basename=$(basename "$SCRIPT")
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@"$ip" "$tmpdir/$basename" "${@:6}"
