#!/bin/bash
#VNET 一键部署脚本
function update_vnet(){
    cd /root/
    #清理上次下载
    rm -rf vnet.tar.gz
    rm -rf vnet/vnet
    rm -rf vnet/vnet.service

    #下载vnet最新版本压缩包
    wget https://github.com/928net/download/raw/master/vnet.tar.gz -O vnet.tar.gz
    tar -xzvf vnet.tar.gz -C vnet

    cd /root/vnet
    chmod +x vnet

    # 服务安装
    ln -P vnet.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable vnet
    systemctl restart vnet
}
update_vnet
