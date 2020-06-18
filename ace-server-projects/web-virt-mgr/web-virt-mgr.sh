##
# 安装WebVirtMgr
#关闭SELinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
#验证cpu是否支持kvm
egrep '(vmx|svm)' /proc/cpuinfo
#关闭防火墙
systemctl stop firewalld
systemctl disable firewalld
#更换yum源(可选,一般不用换)
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum makecacherepo
#安装依赖环境
yum install epel-release net-tools vim unzip zip wget ftp -y
#安装kvm及其依赖项
yum install qemu-kvm libvirt virt-install bridge-utils -y
#验证安装结果
lsmod | grep kvm
#开启kvm服务，并且设置其开机自动启动
systemctl start libvirtd
systemctl enable libvirtd