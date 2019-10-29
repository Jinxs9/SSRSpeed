#!/bin/bash
#VNET 一键部署脚本
function check_system(){
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        release='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        release='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        release='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        release='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        release='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        release='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        release='Raspbian'
        PM='apt'
    else
        release='Unknow'
    fi
	bit=`uname -m`
	if ! [[ ${release} == "Unknow" ]] && [[ ${bit} == "x86_64" ]]; then
	echo -e "当前系统为[${release} ${bit}],\033[32m  可以搭建\033[0m"
	else
	echo -e "\033[31m 脚本停止运行(●°u°●)​ 」，请更换centos7.x 64位系统运行此脚本 \033[0m"
	exit 0;
	fi
}

function install_vnet(){
    # 检测依赖
    if ! [ -x "$(command -v wget)" ]; then
        echo "缺少wget,自动安装"
        ${PM} install wget -y
    fi

    read -p " 节点id: " -i -e node_id
    read -p " 面板通讯密钥: " -i -e api_key

    cd /root/
    #清理上次下载
    rm -rf vnet.tar.gz vnet

    #下载vnet最新版本压缩包
    wget https://raw.githubusercontent.com/Jinxs9/SSRSpeed/master/updatevnet.sh
    chmod +x updatevnet.sh

    #下载vnet最新版本压缩包
    wget https://github.com/928net/download/raw/master/vnet.tar.gz -O vnet.tar.gz
    mkdir -p /root/vnet
    tar -xzvf vnet.tar.gz -C vnet

    cd /root/vnet
    chmod +x vnet

    # 生成配置文件
    cat > config.json << EOF
{
    "node_id":$node_id,
    "key": "$api_key",
    "api_host": "https://zind.cloud"
}
EOF
    echo "配置已生成"

    # 服务安装
    ln -P vnet.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable vnet
    systemctl start vnet
    echo "服务已安装"

    # 关闭防火墙
    if [[ ${release} == "CentOs" ]]; then
        systemctl stop firewalld
        systemctl disable firewalld.service
        echo "防火墙已关闭"
    fi

    se=$(which service)
    sed -i '/vnet restart/d'  /etc/crontab
    sed -i '/updatevnet/d'  /etc/crontab
	echo "15 */6 * * * root ${se} vnet restart" >> /etc/crontab
	echo "0 6 * * * root /root/updatevnet.sh" >> /etc/crontab
    echo "已设置自动重启"
}

check_system
install_vnet
