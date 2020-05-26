## 上传微服务镜像到nexus3镜像仓库
# 微服务名称
serviceName=${1}
# 新版微服务的镜像文件包
dockerImagePath=/ace/docker/image/${serviceName}/jib-image.tar
# 镜像仓库服务器
dockerHubUrl=nexus3.ace.com:8082
# 镜像的tag,当前时间
serviceImageTimeTag=$(date "+%y%m%d%H%M%S")
# 微服务镜像完全名称
serviceImageName=${dockerHubUrl}/${serviceName}
serviceImageNameWithTimeTag=${dockerHubUrl}/${serviceName}:${serviceImageTimeTag}
serviceImageNameWithLatestTag=${dockerHubUrl}/${serviceName}:latest
echo "开始删除之前所有相关镜像"
docker rmi --force $(docker images -a |grep ${serviceName}|awk '{print $3}')||true
echo "加载最新镜像"
docker load < ${dockerImagePath} || true
echo "最新镜像打上tag:${serviceImageNameWithTimeTag} and ${serviceImageNameWithLatestTag}"
docker tag ${serviceName} ${serviceImageNameWithTimeTag}
docker tag ${serviceName} ${serviceImageNameWithLatestTag}
#docker login -u admin -p admin123 ${docker_hub_url}
echo "上传镜像"
docker push ${serviceImageNameWithTimeTag}
docker push ${serviceImageNameWithLatestTag}
#docker logout  ${docker_hub_url}