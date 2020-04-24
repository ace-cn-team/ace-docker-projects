#!/bin/bash
# centos 7最小基础系统 初始化网络与ssh服务
# 安装网络
yum install -y net-tools
yum install -y vim
yum install -y initscripts
# 安装ssh
yum install -y openssh-server
service sshd start