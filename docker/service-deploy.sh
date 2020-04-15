## 部署脚本
service_name=${1}
base_path=/ace/ace-docker-projects/ace-docker-service-projects/${service_name}/docker
docker_image_path=/ace/docker/image/${service_name}/jib-image.tar
docker_compose_yml_path=${base_path}/docker-compose.yml
service_image_name=${service_name}:latest
. /ace/ace-docker-projects/docker/init-docker-compose-env.sh
docker-compose -f ${docker_compose_yml_path} down || true
docker rmi ${service_image_name} || true
docker load < ${docker_image_path} || true
docker-compose -f ${docker_compose_yml_path} up -d