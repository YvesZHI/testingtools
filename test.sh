#!/bin/bash

a=$(ps aux | grep $2 | awk '{print $2}')


a=${a%[[:space:]]*}

if [[ $1 == "top" ]];then
	a=$(echo $a | sed -e 's/ / -p /g')
	a=" -p ${a}"
	echo $a
	top $a
elif [[ $1 == "netstat" ]];then
	a=$(echo $a | sed -e 's/ /\\|/g')
	a="'${a}'"
	echo $a
	netstat -p | grep $a
fi
