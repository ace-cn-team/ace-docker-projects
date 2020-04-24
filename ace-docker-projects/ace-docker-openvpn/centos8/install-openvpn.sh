#将EPEL存储库添加到RHEL/CentOS 8系统，它有openvpn包和所需的依赖项，
#参考在RHEL 8/CentOS 8上安装EPEL存储库（EPEL Repository）的方法。
#我们还需要git从Github中提取代码，确保已安装，运行以下命令：
sudo dnf -y install git
#Clone openvpn-install存储库
#现在使用第一步中安装的git工具Clone openvpn-install存储库：
cd ~
git clone https://github.com/Nyr/openvpn-install.git
cd openvpn-install/
chmod +x openvpn-install.sh
./openvpn-install.sh
firewall-cmd --add-masquerade --permanent