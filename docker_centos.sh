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
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	yum-config-manager --enable docker-ce-edge
	yum_depends=(yum-utils device-mapper-persistent-data lvm2 docker-ce)
	for depend in ${yum_depends[@]}; do
		detect_depends "yum -y install ${depend}"
	done
}

remove_dependencies(){
	yum_depends=(docker docker-common docker-selinux docker-engine)
	for depend in ${yum_depends[@]}; do
		detect_depends "yum -y remove ${depend}"
	done
}

main(){
    remove_dependencies
    install_dependencies
    systemctl start docker
    systemctl enable docker
}

main

