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
    if ! [ -x "$(command -v docker)" ]; then
        echo "缺少docker,自动安装"
        curl -fsSL get.docker.com | sh
    fi

    cd /root/

    docker pull net928/vnet
    docker rm -f jvn$1
    docker run -d --name=jvn$1 -e node_id=$1 -e api_host=https://zind.cloud -e key=$2 --network=host --log-opt max-size=15m --log-opt max-file=3 --restart=always net928/vnet
    
    sed -i '/vnet restart/d'  /etc/crontab
    sed -i '/docker pull/d'  /etc/crontab
    sed -i '/docker restart/d'  /etc/crontab
    echo "15 */6 * * * root /etc/init.d/docker restart" >> /etc/crontab
    echo "45 5 * * * root docker pull net928/vnet" >> /etc/crontab
    echo "50 5 * * * root docker rm -f jvn$1 && docker run -d --name=jvn$1 -e node_id=$1 -e api_host=https://zind.cloud -e key=$2 --network=host --log-opt max-size=15m --log-opt max-file=3 --restart=always net928/vnet" >> /etc/crontab
    echo "已设置定时重启"

    # 关闭防火墙
    if [[ ${release} == "CentOs" ]]; then
        systemctl stop firewalld
        systemctl disable firewalld.service
        echo "防火墙已关闭"
    fi

}

check_system
install_vnet $1 $2
