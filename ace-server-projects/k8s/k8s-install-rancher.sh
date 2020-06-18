#!/bin/bash
# centos7 安装 k8s v1.18.2 之后，在集群上面安装rancher
## 安装配置Helm 3.x
# 配置Helm客户端
wget https://get.helm.sh/helm-v3.2.0-linux-amd64.tar.gz
tar -zxvf helm-v3.2.0-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
## 安装rancher准备工作
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
kubectl create namespace cattle-system
## 安装 cert-manager
# 安装 CustomResourceDefinition 资源
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml
# **重要：**
# 如果您正在运行 Kubernetes v1.15 或更低版本，
# 则需要在上方的 kubectl apply 命令中添加`--validate=false`标志，
# 否则您将在 cert-manager 的 CustomResourceDefinition 资源中收到与
# x-kubernetes-preserve-unknown-fields 字段有关的验证错误。
# 这是一个良性错误，是由于 kubectl 执行资源验证的方式造成的。
# 为 cert-manager 创建命名空间
kubectl create namespace cert-manager
# 添加 Jetstack Helm 仓库
helm repo add jetstack https://charts.jetstack.io
# 更新本地 Helm chart 仓库缓存
helm repo update
# MountVolume.SetUp failed for volume "etcd-certs" : secret "etcd-certs" not found
kubectl -n kube-system create secret generic etcd-certs --from-file=/etc/kubernetes/pki/etcd/server.crt --from-file=/etc/kubernetes/pki/etcd/server.key
# Unable to attach or mount volumes: unmounted volumes=[certs], unattached volumes=[certs cert-manager-webhook-token-flpbz]: timed out waiting for the condition
kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"
# 安装 cert-manager Helm chart
helm install \
 cert-manager jetstack/cert-manager \
 --namespace cert-manager \
 --version v0.12.0
# 等待cert-manager组件安装完华
# kubectl get pods --all-namespaces
helm install rancher rancher-stable/rancher \
 --namespace cattle-system \
 --set hostname=rancher.ace.com \
 --version 2.3.6
