#!/bin/sh

adb connect 192.168.0.14

#timestamp=`date +%Y/%m/%d/ %H:%M`
timestamp=$(date '+%Y/%m/%d/ %H:%M')

while [ 1 ]; do
	echo "$(date '+%Y/%m/%d/ %H:%M:%S')"
	adb shell cat /proc/diskstats | grep "mmcblk0" | grep -v "mmcblk0[[:graph:]]" | awk '{print $3, $12, $14}'
	sleep 2
done