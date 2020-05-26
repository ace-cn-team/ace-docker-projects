#!/bin/bash
## 添加私有镜像仓库
kubectl create secret docker-registry registry-secret \
--docker-server=nexus3.ace.com:8082 \
--docker-username=nexus \
--docker-password= \
--docker-email=279397942@qq.com \
-n ace