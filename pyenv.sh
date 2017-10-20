#!/usr/bin/env bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
UID_NAME=`id $EUID | awk '{print $1}' | awk -F '(' '{print $2}' | awk -F ')' '{print $1}'`
UID_PATH=`cat /etc/passwd | grep $UID_NAME | awk -F ':' '{print $6}' | uniq`

install_pyenv_pyenvvirtualenv() {
git clone git://github.com/yyuu/pyenv.git $UID_PATH/.pyenv
git clone https://github.com/yyuu/pyenv-virtualenv.git $UID_PATH/.pyenv/plugins/pyenv-virtualenv
}

configuring_pyenv() {
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $UID_PATH/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $UID_PATH/.bashrc
exec $SHELL
echo 'eval "$(pyenv init -)"' >> $UID_PATH/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> $UID_PATH/.bashrc
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
    yum_depends=(git gcc openssl openssl-devel)
    for depend in ${yum_depends[@]}; do
        error_detect_depends "yum -y install ${depend}"
    done
}

detect_user() {
if [ $EUID -eq 0 ]; then
    install_dependencies
    install_pyenv_pyenvvirtualenv
    configuring_pyenv
elif [ $EUID -ne 0 ]; then
    git
    RETVAL=$?
    if [ $RETVAL -eq 1 ]; then
        install_pyenv_pyenvvirtualenv
        configuring_pyenv
    else
        echo -e "${red}Error: ${plain} please install git independent packet."
        exit 1
    fi
fi
}

main() {
detect_user
exec $SHELL
}

main