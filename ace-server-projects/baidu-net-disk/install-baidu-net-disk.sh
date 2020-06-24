##
# 检查python,正常centos7 安装2.7.5版本
#python
yum -y install epel-release     #这是安装pip时要用到的东西
yum -y install python-pip
yum clean all
pip install --upgrade pip     #更新 
#如果无法更新可以使用命令：python -m pip install --upgrade pip
pip install bypy
pip install requests