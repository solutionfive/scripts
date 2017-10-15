#!/usr/bin/env bash
# Nagios installation script

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'


disable_selinux() {
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}

disable_firewall() {
    iptables -F
    systemctl stop iptables
    systemctl disable iptables
    echo -e"${green}Info:${plain} iptables have been disabled."
}

error_detect_depends(){
    local command=$1
    local depend=`echo "${command}" | awk '{print $4}'`
    ${command}
    if [ $? != 0 ]; then
        echo -e "${red}Error:${plain} Failed to install ${red}${depend}${plain}"
        echo "Error, please confirm"
        exit 1
    fi
}


install_dependencies() {
    yum_depends=(
    epel-release
    mod_fcgid links perl-Data-Dumper xinetd openssl openssl-devel pcre pcre-devel mariadb-devel mariadb-libs perl-Net-DNS perl-Net-SNMP net-snmp-perl perl-LWP-Protocol-https perl-Cache-Memcached ksh redis
    )
    for depend in ${yum_depends[@]}; do
        error_detect_depends "yum -y install ${depend}"
    done
}


install_nagios() {
    yum_lists=(
    check-mk*
    nagios-plugins-all nagios-plugins-apt nagios-plugins-check-updates nagios-plugins-ifoperstatus nagios-plugins-ifstatus nagios-plugins-nrpe nagios-plugins-radius
    )
    for list in ${yum_lists[@]}; do
        error_detect_depends "yum -y install ${list}"
    done
}

install_thruk() {
    yum_lists=(
    thruk
    )
    rpm -Uvh "https://labs.consol.de/repo/stable/rhel7/i386/labs-consol-stable.rhel7.noarch.rpm"
    for list in ${yum_lists[@]}; do
        error_detect_depends "yum -y install ${list}"
    done
}


disable_selinux
disable_firewall
install_dependencies
install_nagios
install_thruk
disable_selinux
