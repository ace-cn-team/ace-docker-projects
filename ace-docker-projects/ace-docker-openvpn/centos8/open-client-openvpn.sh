##
# 需要先安装openvpn
#关闭SELinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
openvpn --daemon --config /root/centos-server-1.ovpn --log-append /var/log/openvpn.log