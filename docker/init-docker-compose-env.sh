# docker-compose环境变量设置文件
# docker-compose文件绝对路径
export ACE_DOCKER_BASE_DIR=/ace/ace-docker-projects/docker
export ACE_DOCKER_DNS_HTTP_USER=admin
export ACE_DOCKER_DNS_HTTP_PASS=admin
export ACE_DOCKER_DNS_MASQ_CONF_FILE_PATH=${ACE_DOCKER_BASE_DIR}/../ace-docker-dnsmasq/data/dnsmasq.conf
export ACE_DOCKER_OPEN_VPN_DIR_PATH=${ACE_DOCKER_BASE_DIR}/../ace-docker-openvpn/data/openvpn
export ACE_OPENVPN_IP=172.18.0.10
export ACE_DOCKER_MYSQL_ROOT_PASSWORD=root
export ACE_DNS_IP=172.18.0.2
export ACE_MYSQL_IP=172.18.0.5
export ACE_MYSQL_DATA_DIR=${ACE_DOCKER_BASE_DIR}/../ace-docker-mysql80/data
export ACE_REGISTRY_IP=172.18.0.4
export ACE_REGISTRY_MODE=standalone
export ACE_REDIS_COMMON_IP=172.18.0.3
export ACE_JENKINS_IP=172.18.0.6
export ACE_JENKINS_DATA_DIR=${ACE_DOCKER_BASE_DIR}/../ace-docker-jenkins/data
export ACE_NEXUS3_IP=172.18.0.7
export ACE_XXL_JOB_APPLICATION_PROPERTIES_PATH=${ACE_DOCKER_BASE_DIR}/../ace-docker-xxl-job-admin/data/application.properties
export ACE_XXL_JOB_IP=172.18.0.8
export ACE_PROJECT_SUB_NETWORK="172.18.0.0/16"