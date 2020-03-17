script_abs=$(readlink -f "$0")
script_dir=$(dirname $script_abs)
host_dir="${script_dir}/../data/openvpn"
echo "host_dir:${host_dir}"
docker run \
--net host \
--name openvpn \
-v ${host_dir}:/etc/openvpn \
-d \
-p 1194:1194/udp \
-p 1194:1194/tcp \
--privileged \
kylemanna/openvpn:2.4