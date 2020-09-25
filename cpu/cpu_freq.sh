#!/bin/bash


adb connect 192.168.0.14
#core_num=`
#adb shell "grep -c processor /proc/cpuinfo"

#echo $core_num

adb shell "cat /sys/devices/system/cpu -name cpu -type d"