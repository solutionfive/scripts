#!/usr/bin/env bash
#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Please run this scrpts with root account" 1>&2
        exit 1
    fi
}


error_detect_depends() {
    local command=$1
    local depend=`echo "${command}" | awk '{print $4}'`
    ${command}
    if [ $? != 0 ]; then
        echo -e "${red}Error:${plain} Failed to install ${red}${depend}${plain}"
        echo -e "${red}Error, please confirm"
        exit 1
    fi
}

install_dependencies() {
    apt_depends=(
    build-essential iperf screen sudo lsof elinks vim make gcc-4.9 g++-4.9 libgnutls28-dev libprotobuf-c0-dev libtalloc-dev libhttp-parser-dev libpcl1-dev libopts25-dev autogen protobuf-c-compiler gperf liblockfile-bin nuttcp lcov libuid-wrapper libpam-oath  libwrap0-dev libpam0g-dev liblz4-dev libseccomp-dev libreadline-dev libnl-route-3-dev libkrb5-dev liboath-dev libunistring0
    )
    apt-get update -y && apt-get upgrade -y
    for depend in ${apt_depends[@]}; do
        error_detect_depends "apt-get -y install ${depend}"
    done
}

add_new_user() {
    mkdir /home/rick/.ssh -p
    useradd rick -s /bin/bash -d /home/rick
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCj3sFcfqI0ybPHSsdyFbV7+yKmWr562meCPqbisIUGy8qYDkrtjZ6e+uREAyww824HLTMhAp6qMzqekUqVelgUgtTJa/PH59ggsXVDuF3/h8pYvNMCtOo+RCHFcXLmvXUKmuUJ1xJx6qaFDH5IGA3uJakoyXQgZNCU3o6aXCKuZ3E8zATrmOJ7MMd5pyJRYSfwd3VdCL3p4MTf4zWXcJZc00i+SC34ME04qG8owqIoJ//UkMJZs7eHamV3gi+TwqU0pWH4kTNVrljncANcSnWKbsAcIkHPy4BfglzQJGJZQSeENQU5xD+MgPvxSBARhLvUsNwlz5wBpGLCk6yd2R8H" >> /home/rick/.ssh/authorized_keys
    chmod 755 /home/rick/.ssh
    chown rick:rick /home/rick/.ssh
    chmod 600 /home/rick/.ssh/authorized_keys
    chown rick:rick /home/rick/.ssh/authorized_keys
    echo "%rick     ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
    mkdir /home/mike/.ssh -p
    useradd mike -s /bin/bash -d /home/mike
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSSA4r8ud0zPHtt/LEPyrEqu7O6L9jkt9UoYLJf+FD0lS5d9dRuVUxkiw4rlW+kPTcd8FP5rFXkQbLOoT1ZlsefmAC5hS1H4k9bGkrOY//iK1b9QI2G01w0eqBY0MDMPnCG1batSkFxngoaEL/yoeUic5MXgxXWzIIupUmCUOxDkDCQSyBgTOYtGLuzE/Qi/PZlSotgnyPANdVWE29DtTc+HQSb8xiS87nk/CuNz0SNZvinQ9apRMbEBvpslQjae2F5oFsmWLD3Z5hU5ei3QaN7aj0kNV6DXBeg/9gNBh37l74STviV8z9tpaeRv2Z85lYpa+UcV6W+5huRRO/GKyz" >> /home/mike/.ssh/authorized_keys
    chmod 755 /home/mike/.ssh
    chown mike:mike /home/mike/.ssh
    chmod 600 /home/mike/.ssh/authorized_keys
    chown mike:mike /home/mike/.ssh/authorized_keys
    echo "%mike     ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
}

main() {
    check_root
    install_dependencies
    add_new_user
}
main