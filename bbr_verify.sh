#!/usr/bin/env bash

verify() {
KERNEL_VER=$(uname -r | awk -F'.' '{print $1}')
SYSCTL_CONGESTION_RET=$(sysctl net.ipv4.tcp_congestion_control | awk -F'=' '{print $2}')
SYSCTL_QDISC_RET=$(sysctl net.core.default_qdisc | awk -F'=' '{print $2}')
LSMOD_RET=$(lsmod | grep bbr  | awk -F' '  '{print $1}')

if [ $KERNEL_VER == 4 ] && [ $SYSCTL_CONGESTION_RET == 'bbr' ] && [ $SYSCTL_QDISC_RET == 'bbr' ] && [ $LSMOD_RET == 'tcp_bbr' ]; then
    echo -e 'BBR has been Verified.'
else
    echo -e 'BBR failed with kernel_version: $KERNEL_VER, congestion: $SYSCTL_CONGESTION_RET, qdisc: $SYSCTL_QDISC_RET, lsmod: $LSMOD_RET'
fi

}

verify