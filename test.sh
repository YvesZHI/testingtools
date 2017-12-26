#!/bin/bash

a=$(pgrep -f $2)

if [[ $1 == "top" ]];then
	total=$(echo $a | tr -cd ' ' | wc -c)
	echo "total processes: "$total
	echo $a
	top
elif [[ $1 == "netstat" ]];then
	a=$(echo $a | sed -e 's/ /\\|/g')
	a="'${a}'"
	name=`hostname`
	netstat -p | grep $a | awk -v n=$name '{if ($5 !~ "localhost" && $5 !~ n) {print $5;}}'
fi
