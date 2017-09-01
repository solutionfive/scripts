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
    openssl openssl-devel gettext gcc autoconf libtool automake make asciidoc xmlto udns-devel libev-devel pcre pcre-devel links elinks git net-tools gnutls-devel libev-devel tcp_wrappers-devel pam-devel lz4-devel libseccomp-devel readline-devel libnl3-devel krb5-devel liboath-devel radcli-devel protobuf-c-devel libtalloc-devel pcllib-devel autogen-libopts-devel autogen protobuf-c gperf lockfile-progs nuttcp lcov uid_wrapper pam_wrapper nss_wrapper socket_wrapper gssntlmssp pam_oath screen vim iperf screen
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

add_new_user() {
    useradd rick
    mkdir /home/rick/.ssh -p
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCj3sFcfqI0ybPHSsdyFbV7+yKmWr562meCPqbisIUGy8qYDkrtjZ6e+uREAyww824HLTMhAp6qMzqekUqVelgUgtTJa/PH59ggsXVDuF3/h8pYvNMCtOo+RCHFcXLmvXUKmuUJ1xJx6qaFDH5IGA3uJakoyXQgZNCU3o6aXCKuZ3E8zATrmOJ7MMd5pyJRYSfwd3VdCL3p4MTf4zWXcJZc00i+SC34ME04qG8owqIoJ//UkMJZs7eHamV3gi+TwqU0pWH4kTNVrljncANcSnWKbsAcIkHPy4BfglzQJGJZQSeENQU5xD+MgPvxSBARhLvUsNwlz5wBpGLCk6yd2R8H" >> /home/rick/.ssh/authorized_keys
    chmod 755 /home/rick/.ssh
    chown rick:rick /home/rick/.ssh
    chmod 600 /home/rick/.ssh/authorized_keys
    chown rick:rick /home/rick/.ssh/authorized_keys
    echo "%rick     ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
}

disable_root_ssh() {
    sed -i 's/^#PermitRootLogin\s*yes$/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i 's/^#PubkeyAuthentication\s*yes$/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
    yes_no=n
    read -p "Add New User with ssh key file? (y/n) (Default User: rick)" yes_no
    [ $yes_no == 'y' ] && echo -e "Adding New User." && add_new_user
    systemctl restart sshd
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Please run this scripts with root account." 1>&2
        exit 1
    fi
}

main() {
    check_root
    disable_selinux
    disable_firewall
    install_dependencies
    yum -y update
    yes_no=n
    read -p "Install kernelv4? (y/n) (default: n)" yes_no
    [ $yes_no == 'y' ] && echo -e "Installing kernelv4" && install_kernel4.12
    disable_root_ssh
    for i in {5..1} ; do echo "Your server will restart in $i seconds, Ctrl+C to disrupt it if you need"; sleep $i ; done
    init 6
}

main


