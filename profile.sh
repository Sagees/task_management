#!/bin/bash

cpu_parsing() {
	echo parsing cpu info
	echo CpuUser% CpuSys% >> stat_cpu
	#14 15 16 17

	while read line
	do
		ut_cur=`echo $line | awk '{print $14}'`
		st_cur=`echo $line | awk '{print $15}'`
		cut_cur=`echo $line | awk '{print $16}'`
		cst_cur=`echo $line | awk '{print $17}'`

		if [ -n "$ut_prev" ]; then
			echo $ut_cur $ut_prev $st_cur $st_prev $cut_cur $cut_prev $cst_cur $cst_prev \
				| awk '{printf "%d %d\n", (($1-$2)), (($3-$4))}' >> stat_cpu
		fi

		ut_prev=$ut_cur
		st_prev=$st_cur
		cut_prev=$cut_cur
		cst_prev=$cst_cur
	done < cpu
}

mem_parsing() {
	echo parsing memory info
	echo Total Memory Size \(RSS\)\(MB\) >> stat_mem

	while read line
	do
		echo $line | awk '{printf "%.2f\n", ($2*4096)/1000000}' >> stat_mem

	done < mem
}

net_parsing() {
	echo parsing network info
	echo RX\(KB/s\) TX\(KB/s\) >> stat_net
	rx_prev=""

	while read line
	do
		rx_cur=`echo $line | awk '{print $2}'`
		tx_cur=`echo $line | awk '{print $10}'`

		if [ -n "$rx_prev" ]; then
			echo $rx_cur $rx_prev $tx_cur $tx_prev | awk '{printf "%.2f %.2f\n", ($1-$2)/1000, ($3-$4)/1000}' >> stat_net
		fi

		rx_prev=$rx_cur
		tx_prev=$tx_cur
	done < net
}

io_parsing() {
	echo parsing i/o info
	echo Read\(KB/s\) Write\(KB/s\) >> stat_io
	rwi=0
	read_prev=""

	while read line
	do

		if [ $rwi -eq 2 ]; then
			if [ -n "$read_prev" ]; then
				echo $read_cur $read_prev $write_cur $write_prev | awk '{printf "%.2f %.2f\n", ($1-$2)/1000, ($3-$4)/1000}' >> stat_io
			fi
			rwi=0
			read_prev=$read_cur
			write_prev=$write_cur
		else
			if [ $rwi -eq 0 ]; then
				read_cur=`echo $line | awk '{print $2}'`
			else
				write_cur=`echo $line | awk '{print $2}'`
			fi
			rwi=$(($rwi+1))
		fi

	done < io
}

end_parsing() {
	cpu_parsing
	mem_parsing
	net_parsing
	io_parsing
	echo
	echo END
	echo
	exit
}

#get pid
while :
do
	pinfo=`adb shell "dumpsys activity | grep top-activity"`
	pname=`echo $pinfo | cut -d: -f 4`
	pname=`echo $pname | cut -d/ -f 1`
	if [ $pname != "com.android.launcher3" ]; then
		break
	fi
done

info=`adb shell "dumpsys activity | grep top-activity"`
pid=`echo $info | cut -d: -f 3 | awk '{print $2}'`
echo $info
echo $pid

#make command
thread_script="ls /proc/${pid}/task"
cpu_script="cat /proc/${pid}/stat"
cpu_usage_script="ps -o pcpu -p ${pid} | tail -n 1"
mem_script="cat /proc/${pid}/statm"
net_script="cat /proc/${pid}/net/dev"
io_script="cat /proc/${pid}/io"

#make directory based on proc name
name=`adb shell $cpu_script | awk '{print $2}'`
name=${name:1:-1}
echo $name

if [ ! -d "${name}" ]; then
	mkdir $name
	cd $name
else
	echo already exist, so remove 
	cd $name
	rm -rf *
fi

trap end_parsing SIGINT

# start profile
adb shell $thread_script > threads_pid

while :
do
	adb shell $cpu_script >> cpu
	adb shell $cpu_usage_script >> cpu_usage
	adb shell $mem_script >> mem
	adb shell $net_script | grep eth0 >> net
	adb shell $io_script | grep bytes >> io

	sleep 1
done

