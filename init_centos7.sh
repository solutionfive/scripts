#!/usr/bin/env bash
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

error_detect_depends() {
    local command=$1
    local depend=`echo "${command}" | awk '{print $4}'`
    ${command}
    if [ $? != 0 ]; then
        echo -e "${red}Error:${plain} Failed to install ${red}${depend}${plain}"
        echo "${red}Error, please confirm"
        exit 1
    fi
}

install_dependencies() {
    yum_depends=(
    epel-release
    openssl openssl-devel gettext gcc autoconf libtool automake make asciidoc xmlto udns-devel libev-devel pcre pcre-devel links elinks git net-tools
    )
    for depend in ${yum_depends[@]}; do
        error_detect_depends "yum -y install ${depend}"
    done
}

install_kernel4.12() {
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
    yum --enablerepo=elrepo-kernel -y install kernel-ml kernel-ml-devel
}

main() {
    disable_selinux
    disable_firewall
    install_dependencies
    yes_no=n
    read -p "Install kernelv4? (y/n) (default: n)" yes_no
    [ $yes_no == 'y' ] && echo -e "Installing kernelv4" && install_kernel4.12
    yum -y update
}

main


