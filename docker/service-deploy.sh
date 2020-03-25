## 部署脚本
service_name=${1}
base_path=/ace/docker/image/${service_name}
docker_compose_yml_path=${base_path}/docker-compose.yml
service_image_name=${service_name}:latest
. /ace/ace-docker-projects/docker/init-docker-compose-env.sh
docker-compose -f ${docker_compose_yml_path} down || true
docker rmi ${service_image_name} || true
docker load < ${base_path}/jib-image.tar || true
docker-compose -f ${docker_compose_yml_path} up -d