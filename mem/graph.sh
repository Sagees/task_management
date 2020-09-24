#!/bin/bash
#
# Parameters:
#
#       config   (required)
#       autoconf (optional - used by munin-config)
#

COMPONENT_NAME="GDM"
COMPONENT_PID_FILE="/var/run/gdm3.pid"

if [ "$1" = "autoconf" ]; then
        if [ -r /proc/stat ]; then
                echo yes
                exit 0
        else
                echo "no (/proc/stat not readable)"
                exit 1
        fi
fi

if [ "$1" = "config" ]; then   
        echo "graph_title $COMPONENT_NAME memory usage"
        echo 'graph_vlabel'
        echo "graph_category Processes"
        echo "graph_info This graph shows the amount of memory used by the $COMPONENT_NAME processes"
        echo "${COMPONENT_NAME}_vmpeak.label $COMPONENT_NAME VmPeak"
        echo "${COMPONENT_NAME}_vmsize.label $COMPONENT_NAME VmSize"
        echo "${COMPONENT_NAME}_vmrss.label $COMPONENT_NAME VmRSS"
        echo 'graph_args --base 1024'
        exit 0
fi

check_memory ()
# $1 - PID location
# $2 - process_label
{
        pid_location=$1
        process_label=$2
        read pid < $pid_location
        procpath="/proc/$pid/status"
        if [ ! -e $procpath ]  || [ -z $pid ]
        then
                echo "${process_label}_vmpeak.value 0"
                echo "${process_label}_vmsize.value 0"
                echo "${process_label}_vmrss.value 0"
                exit 0
        fi

        VmPeak=`grep VmPeak /proc/$pid/status|awk '{print $2}'`
        VmSize=`grep VmSize /proc/$pid/status|awk '{print $2}'`
        VmRSS=`grep VmRSS /proc/$pid/status|awk '{print $2}'`

        echo "${process_label}_vmpeak.value $(( $VmPeak * 1024 ))"
        echo "${process_label}_vmsize.value $(( $VmSize * 1024 ))"
        echo "${process_label}_vmrss.value $(( $VmRSS * 1024 ))"
}

check_memory $COMPONENT_PID_FILE $COMPONENT_NAME