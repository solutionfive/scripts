#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

echo "GigsGigsCloud-BBR安装脚本"
echo "三种版本由不同开发者开发(推荐使用第三款)"
echo "1.安装BBR1版(支持Centos/Ubuntu/Debian)"
echo "2.安装BBR2版(支持Debian/Ubuntu)"
echo "3.安装BBR增强/魔改版(支持Debian/Ubuntu)"
echo "4.安装BBR2增强/魔改包(先安装2之后安装)"

while :; do echo
	read -p "请选择： " devc
	[ -z "$devc" ] && ssr && break
	if [[ ! $devc =~ ^[1-3]$ ]]; then
		echo "输入错误! 请输入正确的数字!"
	else
		break	
	fi
done

if [[ $devc == 1 ]];then
	wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh
fi

if [[ $devc == 2 ]];then
	wget --no-check-certificate -qO 'BBR.sh' 'https://moeclub.org/attachment/LinuxShell/BBR.sh' && chmod a+x BBR.sh && bash BBR.sh -f
fi

if [[ $devc == 3 ]];then
	wget -N --no-check-certificate https://raw.githubusercontent.com/FunctionClub/YankeeBBR/master/bbr.sh && bash bbr.sh install
fi

if [[ $devc == 4 ]];then
	wget --no-check-certificate -qO 'BBR_POWERED.sh' 'https://moeclub.org/attachment/LinuxShell/BBR_POWERED.sh' && chmod a+x BBR_POWERED.sh && bash BBR_POWERED.sh
fi