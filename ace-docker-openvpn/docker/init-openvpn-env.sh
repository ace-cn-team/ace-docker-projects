#!/bin/bash
# 输入参数：环境参数脚本绝对路径
param_script_abs=${1}
# 获取当前脚本绝对路径
script_abs=$(readlink -f "$0")
# 获取配置数据目录路径
tmp_script_dir="$(dirname ${script_abs})/../data/openvpn"
# 输入参数：服务器绑定的IP
param_tmp_server_id=${2}
# 获取服务器默认IP地址
tmp_server_id=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/')
# 基础目录路径
data_dir=${param_script_abs:=${tmp_script_dir}}
# openvpn ip 地址，用于生成连接证书
server_id=${param_tmp_server_id:=${tmp_server_id}}
echo "data_dir:${data_dir}"
echo "server_id:${server_id}"
#generate config
gen_conf(){
  echo "------ generate config start ------"
  echo "ip addr:${server_id}"
  docker run -v ${data_dir}:/etc/openvpn --rm kylemanna/openvpn:2.4 ovpn_genconfig -u udp://${server_id}
  echo "------ generate config end success ------"
}
#
#
#generate cart
gen_ovpn_initpki(){
  echo "------generate ovpn_initpki start ------"
  docker run -v ${data_dir}:/etc/openvpn --rm -it kylemanna/openvpn:2.4 ovpn_initpki
  echo "------ generate ovpn_initpki success ------"
}
#
#
#generate_client_cart
gen_client_cart(){
  echo "------generate gen_client_cart start ------"
  docker run -v ${data_dir}:/etc/openvpn --rm -it kylemanna/openvpn:2.4 easyrsa build-client-full caspar nopass
  echo "------ generate gen_client_cart success ------"
}
#
#
#export ovpn
export_client_ovpn(){
  echo "------generate export_client_ovpn start ------"
  docker run -v ${data_dir}:/etc/openvpn --rm kylemanna/openvpn:2.4 ovpn_getclient caspar > ${data_dir}/caspar.ovpn
  echo "------ generate export_client_ovpn success ------"
}
#

gen_conf && gen_ovpn_initpki && gen_client_cart && export_client_ovpn