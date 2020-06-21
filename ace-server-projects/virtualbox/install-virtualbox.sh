#首先下载编译vboxdrv内核模块所需的构建工具：
yum install -y kernel-devel kernel-headers make patch gcc
wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -P /etc/yum.repos.d
yum install -y VirtualBox-6.1