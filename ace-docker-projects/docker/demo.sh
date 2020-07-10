#!/bin/bash
script_abs=$(readlink -f "$0")
script_dir=$(dirname $script_abs)
server_id=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/')
openvpn_base_dir=${script_dir}/../ace-docker-openvpn
openvpn_data_dir=${openvpn_base_dir}/data/openvpn
openvpn_docker_script_dir=${openvpn_base_dir}/docker
echo "script_abs:${script_abs}"
echo "script_dir:${script_dir}"
echo "openvpn_base_dir:${openvpn_base_dir}"
echo "openvpn_data_dir:${openvpn_data_dir}"
echo "openvpn_docker_script_dir:${openvpn_docker_script_dir}"
echo "server_id:${server_id}"

