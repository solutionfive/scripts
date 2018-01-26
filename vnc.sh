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
	yum_depends=(tigervnc-server)
	for depend in ${yum_depends[@]}; do
		detect_depends "yum -y install ${depend}"
	done
}

add_vnc_user(){
    (! id rick) && useradd rick
}

config_files(){
    if [ ! -f /lib/systemd/system/vnc* ]; then
        echo "Error, /lib/systemd/system/vnc* not exist."
        exit 1
    else
        cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
        echo "cp systemd file."
    fi
    sed -i '/^ExecStartPre.*/d' /etc/systemd/system/vncserver@:1.service
    sed -i '/^ExecStart.*/d' /etc/systemd/system/vncserver@:1.service
    sed -i '/^PIDFile.*/d' /etc/systemd/system/vncserver@:1.service
    sed -i '/^ExecStop.*/d' /etc/systemd/system/vncserver@:1.service
    sed -i '/^\[Ins.*/d' /etc/systemd/system/vncserver@:1.service
    sed -i '/^WantedBy.*/d' /etc/systemd/system/vncserver@:1.service
    echo "ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'" >> /etc/systemd/system/vncserver@:1.service
    echo 'ExecStart=/sbin/runuser -l rick -c "/usr/bin/vncserver %i -geometry 1280x1024"' >> /etc/systemd/system/vncserver@:1.service
    echo "PIDFile=/home/rick/.vnc/%H%i.pid" >> /etc/systemd/system/vncserver@:1.service
    echo "ExecStop=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'" >> /etc/systemd/system/vncserver@:1.service
    echo "[Install]" >> /etc/systemd/system/vncserver@:1.service
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/vncserver@:1.service
    systemctl daemon-reload
    systemctl enable vncserver@:1.service
    ln -s '/etc/systemd/system/vncserver@:1.service' '/etc/systemd/system/multi-user.target.wants/vncserver@:1.service'
}


main(){
    yum -y groupinstall "GNOME Desktop"
    install_dependencies
    add_vnc_user
    config_files
}

main

