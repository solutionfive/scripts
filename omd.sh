#!/usr/bin/env bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

detect_depends(){
	local command=$1
	local depend=`echo "${command}" | awk '{print $4}'`
	${command}
	if [ $? != 0 ]; then
		echo -e "${red}Error:${plain} Failed to install ${red}${depend}${plain}"
		echo "Error, please confirm."
		exit 1
	fi
}

install_dependencies(){
	yum_depends=(https://labs.consol.de/repo/stable/rhel7/x86_64/omd-2.60-labs-edition-rhel7.x86_64.rpm)
	for depend in ${yum_depends[@]}; do
		detect_depends "yum -y install ${depend}"
	done
}


main(){
    install_dependencies
}

main

