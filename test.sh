#!/bin/bash

LM_PATH=""
archi=$(dpkg --print-architecture)
if [[ "$archi" =~ "amd" ]]; then
	LM_PATH="./bin/*/"
else
	LM_PATH="./bin"
fi

function get_lmbench3 {
	wget http://www.bitmover.com/lmbench/lmbench3.tar.gz
	tar xzf lmbench3.tar.gz
	rm lmbench3.tar.gz
}


if [[ $1 == "-h" || $1 == "--help" ]]; then
	printf "usage: ./test.sh [COMMAND] [ARGS]...\n"
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
	printf "	perf		perf [EXE] [ARGS_OF_EXE]... displays the number of cache-misses\n"
	printf "								the number of instructions\n"
	printf "								the number of cycles\n"
	printf "			of [EXE]\n"
	printf "	flamegraph	flamegraph [DURATION] generates the flamegraph file recorded the\n"
	printf "			perf data during [DURATION]\n"
	printf "	ps		ps [TARGET] list the process info about the target\n"
	printf "	stream		stream generated a file in the directory /home about memory transfer rates in MB/s\n"
	printf "	lat_ctx		lat_ctx [SIZE_IN_BYTES] [NUM_OF_PROCS] generates the context switching time\n"
	printf "	dfx		ONLY FOR ARM!\n"
	printf "			dfx [TYPE] [DURATION] generates the dfx results in the direcoty /home\n"
	printf "		        TYPE	description\n"
	printf "			1	DDR and LLC\n"
	printf "			2	HHA and SLLC\n"
	printf "			3	AA read\n"
	printf "			4	AA write\n"
	printf "			5	AA copyback\n"
	printf "			6	PA and HLLC\n"
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
	existed=$(which nload)
	if [[ $existed == "" ]]; then
		apt update
		apt install nload
	fi
	nload $(grep inet /etc/network/interfaces | grep -v lo)
elif [[ $1 == "vmstat" ]];then
	vmstat $2 $3
elif [[ $1 == "sar" ]];then
	existed=$(which sar)
	if [[ $existed == "" ]]; then
		apt update
		apt install sysstat
	fi
	sar -B $2 $3
elif [[ $1 == "perf" ]];then
	existed=$(which perf)
	if [[ $existed == "" ]]; then
		apt update
		apt install linux-tools-common linux-tools-$(uname -r)
	fi
	perf stat -e cache-misses,instructions,cycles,context-switches ${@:2}
elif [[ $1 == "flamegraph" ]];then
	perf record -a -g -- sleep $2
	NAME="flamegraph"
	i=$(ls | grep "$NAME[0-9]*\.svg" | wc -l)
	name=$NAME$i.svg
	perf script | ./flamegraph/stackcollapse-perf.pl | ./flamegraph/flamegraph.pl > $name
	rm perf.data
	echo "$name generated"
elif [[ $1 == "ps" ]];then
	ps -Lo psr,pid,tid,etime,cputime,comm $(pgrep $2)
elif [[ $1 == "stream" ]];then
	if [ ! -d "lmbench3" ]; then
		get_lmbench3
	fi
	cd lmbench3
	if [ ! -f ./bin/stream ];then
		make > /dev/null 2>&1
	fi
	$LM_PATH/stream > /home/stream 2>&1
elif [[ $1 == "lat_ctx" ]];then
	if [ ! -d "lmbench3" ]; then
		get_lmbench3
	fi
	cd lmbench3
	if [ ! -f ./bin/lat_ctx ];then
		make > /dev/null 2>&1
	fi
	$LM_PATH/lat_ctx -s $2 processes $3 > "/home/lat_ctx_$2_$3" 2>&1
elif [[ $1 == "dfx" && $(uname -p) =~ "arch" ]];then
	if [ ! -f /proc/HI1616_DFX ];then
		cd ./hi1616dfx
		make clean
		make
		insmod dfx.ko
		make clean
	fi
	echo "$2 $3" > /proc/HI1616_DFX
	echo "Go to /home in $3 second(s) to get the result."
	(
		cd /home
		if [[ $2 == "1" ]];then
			while [ ! -f /home/llc_ddr_statistic ];do
				sleep 1
			done
			python /root/testingtools/hi1616dfx/parse.py -c llc -t $3 -o llc > /dev/null
		elif [[ $2 == "2" ]];then
			while [ ! -f /home/hha_sllc_statistic ];do
				sleep 1
			done
			python /root/testingtools/hi1616dfx/parse.py -c hha -t $3 -o hha > /dev/null
			python /root/testingtools/hi1616dfx/parse.py -c sllc -t $3 -o sllc > /dev/null
		elif [[ $2 == "3" ]];then
			while [ ! -f /home/aa_rd_statistic ];do
				sleep 1
			done
			python /root/testingtools/hi1616dfx/parse.py -c aa_rd -t $3 -o aa_rd > /dev/null
		elif [[ $2 == "4" ]];then
			while [ ! -f /home/aa_wr_statistic ];do
				sleep 1
			done
			python /root/testingtools/hi1616dfx/parse.py -c aa_wr -t $3 -o aa_wr > /dev/null
		elif [[ $2 == "5" ]];then
			while [ ! -f /home/aa_cb_statistic ];do
				sleep 1
			done
			python /root/testingtools/hi1616dfx/parse.py -c aa_cb -t $3 -o aa_cb > /dev/null
		elif [[ $2 == "6" ]];then
			while [ ! -f /home/pa_statistic ];do
				sleep 1
			done
			python /root/testingtools/hi1616dfx/parse.py -c pa -t $3 -o pa > /dev/null
			python /root/testingtools/hi1616dfx/parse.py -c hllc -t $3 -o hllc > /dev/null
		else
			echo "illegal parameters"
		fi
	) &
else
	echo "command $1 not support"
	echo 'contact:'
	echo '* Huawei *		z00436880'
	echo '* github *		https://github.com/YvesZHI/testingtools'
	echo '* email  *		yuhui.zhi01@gmail.com'
fi

