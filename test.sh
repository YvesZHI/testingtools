#!/bin/bash

if [[ $1 == "-h" || $1 == "--help" ]]; then
	printf "usage: ./test.sh [COMMAND] [PARAMETER]...\n"
	printf "This script integrates common system monitor commands.\n\n"
	printf "	top		top [TARGET] displays the information of the command top\n"
	printf "			including the number of processes whose names contain [TARGET]\n"
	printf "			top --help\n"
	printf "	netstat		netstat [TARGET] displays the number of connection of outside network\n"
	printf "						  the number of IPC\n"
	printf "						  the number of Unix domain socket\n"
	printf "			of processes whose names contain [TARGET]\n"
	printf "	vmstat		vmstat --help\n"
	printf "	sar		sar --help\n"
	printf "	perf		perf [EXE] [OPTIONS_OF_EXE]... displays the number of cache-misses\n"
	printf "								the number of instructions\n"
	printf "								the number of cycles\n"
	printf "			of [EXE]\n"
	exit 0
fi


if [[ $1 == "top" ]];then
	a=$(pgrep -f $2)
	total=$(echo $a | tr -cd ' ' | wc -c)
	echo "total processes: "$total
	echo $a
	top
elif [[ $1 == "netstat" ]];then
	a=$(pgrep -f $2)
	a=$(echo $a | sed -e 's/ /\\|/g')
	a="'${a}'"
	name=`hostname`
	netstat -p | grep $a | awk -v n=$name 'BEGIN {numExter=0; numSocket=0; numIPC=0;} { if ($5 ~ "localhost" || $5 ~ n){ numIPC++; } else if ($5 ~ "STREAM"){ numSocket++; } else {numExter++;} } END {print "Internet: ", numExter, "\tIPC: ", numIPC, "\tUnix domain socket: ", numSocket}'
elif [[ $1 == "vmstat" ]];then
	vmstat $2 $3
elif [[ $1 == "sar" ]];then
	sar -B $2 $3
elif [[ $1 == "perf" ]];then
	perf stat -e cache-misses,instructions,cycles ${@:2}
elif [[ $1 == "flamegraph" ]];then
	perf record -a -g -- sleep $2
	perf script | /root/flamegraph/stackcollapse-perf.pl | /root/flamegraph/flamegraph.pl > res.svg
	rm perf.data
else
	echo "command $1 not support"
	echo 'contact:'
	echo '* Huawei *		z00436880'
	echo '* github *		https://github.com/YvesZHI/testingtools'
	echo '* email  *		yuhui.zhi01@gmail.com'
fi

