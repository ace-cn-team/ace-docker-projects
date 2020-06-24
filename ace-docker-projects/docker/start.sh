#!/bin/bash
script_abs=$(readlink -f "$0")
script_dir=$(dirname $script_abs)
server_id=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/')
openvpn_base_dir=${script_dir}/../ace-docker-openvpn
openvpn_data_dir=${openvpn_base_dir}/data/openvpn
openvpn_docker_script_dir=${openvpn_base_dir}/docker
echo "openvpn_base_dir:${openvpn_base_dir}"
echo "openvpn_data_dir:${openvpn_data_dir}"
echo "openvpn_docker_script_dir:${openvpn_docker_script_dir}"
echo "server_id:${server_id}"
# 拉取openvpn
#docker pull kylemanna/openvpn:2.4
#
#
# 生成openvpn环境配置
source ${openvpn_docker_script_dir}/init-openvpn-env.sh ${openvpn_data_dir} ${server_id}
#
#
# 添加开放端口
firewall-cmd --add-port=10001/tcp --permanent
firewall-cmd --add-port=8080/tcp --permanent
# 重启防火墙
systemctl restart firewalld.service