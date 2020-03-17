# docker-compose环境变量设置文件
# docker-compose文件绝对路径
export ACE_DOCKER_BASE_DIR=/caspar/ace-docker-projects/docker
export ACE_DOCKER_DNS_HTTP_USER=admin
export ACE_DOCKER_DNS_HTTP_PASS=admin
export ACE_DOCKER_DNS_MASQ_CONF_FILE_PATH=${ACE_DOCKER_BASE_DIR}/../ace-docker-dnsmasq/data/dnsmasq.conf
export ACE_DOCKER_OPEN_VPN_DIR_PATH=${ACE_DOCKER_BASE_DIR}/../ace-docker-openvpn/data/openvpn