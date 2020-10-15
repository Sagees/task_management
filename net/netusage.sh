#!/bin/bash

adb connect 192.168.0.14

#timestamp=$(date '+%Y/%m/%d/ %H:%M:%S')

while [ 1 ]; do
	echo "$(date '+%Y/%m/%d/ %H:%M:%S')"
	adb shell cat /proc/net/xt_qtaguid/stats | grep -v "lo" | awk '{print $2, $5, $6, $8}'
	sleep 2
done