script_abs=$(readlink -f "$0")
script_dir=$(dirname $script_abs)
echo "init dnsmasq ${script_dir}"
docker run \
--name dns-dnsmasq \
-d \
--net ace-network \
--ip 172.18.0.2 \
-p 53:53/udp \
-p 53:53/tcp \
-p 10001:8080 \
-v ./dnsmasq.conf:/etc/dnsmasq.conf \
-e "HTTP_USER=admin" \
-e "HTTP_PASS=admin" \
--restart always \
jpillora/dnsmasq:1