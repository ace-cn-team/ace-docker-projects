#!/bin/bash
# centos7 安装 k8s v1.18.2 master节点脚本
# https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
#
# 禁用firewall
systemctl stop firewalld.service
systemctl disable firewalld.service
#
# 安装iptables
yum install -y iptables-services
systemctl enable iptables
systemctl start iptables
#
# 确保 iptables 工具不使用 nftables 后端,
# https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#%E7%A1%AE%E4%BF%9D-iptables-%E5%B7%A5%E5%85%B7%E4%B8%8D%E4%BD%BF%E7%94%A8-nftables-%E5%90%8E%E7%AB%AF
update-alternatives --set iptables /usr/sbin/iptables-legacy
#
# 安装docker
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y dnf
dnf install -y https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.13-3.1.el7.x86_64.rpm
dnf install -y docker-ce
systemctl enable docker.service
systemctl start docker.service
#
# 关闭swap,k8s安装限制
swapoff -a
#
# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
# 一些 RHEL/CentOS 7 的用户曾经遇到过问题：由于 iptables 被绕过而导致流量无法正确路由的问题。您应该确保 在 sysctl 配置中的
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
#
# 安装k8s镜像使用阿里云
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
#
#
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
#
systemctl enable --now kubelet
systemctl start kubelet
#
# 处理翻墙下载镜像的问题
docker pull gotok8s/kube-apiserver:v1.18.2
docker pull gotok8s/kube-controller-manager:v1.18.2
docker pull gotok8s/kube-scheduler:v1.18.2
docker pull gotok8s/kube-proxy:v1.18.2
docker pull gotok8s/pause:3.2
docker pull gotok8s/etcd:3.4.3-0
docker pull gotok8s/coredns:1.6.7
# 重命名
docker tag docker.io/gotok8s/kube-apiserver:v1.18.2 k8s.gcr.io/kube-apiserver:v1.18.2
docker tag docker.io/gotok8s/kube-controller-manager:v1.18.2 k8s.gcr.io/kube-controller-manager:v1.18.2
docker tag docker.io/gotok8s/kube-scheduler:v1.18.2 k8s.gcr.io/kube-scheduler:v1.18.2
docker tag docker.io/gotok8s/kube-proxy:v1.18.2 k8s.gcr.io/kube-proxy:v1.18.2
docker tag docker.io/gotok8s/pause:3.2 k8s.gcr.io/pause:3.2
docker tag docker.io/gotok8s/etcd:3.4.3-0 k8s.gcr.io/etcd:3.4.3-0
docker tag docker.io/gotok8s/coredns:1.6.7 k8s.gcr.io/coredns:1.6.7
#
kubeadm init
# root user run this
export KUBECONFIG=/etc/kubernetes/admin.conf
# 安装 k8s weave网络管理插件（有其它网络插件选择）。创建时间比较长
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# 检查网络是否创建成功
kubectl get pods --all-namespaces
# 开启单机集群模式，默认关闭
#kubectl taint nodes --all node-role.kubernetes.io/master-
# 添加worker节点
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#join-nodes
#
#If you do not have the token, you can get it by running the following command on the control-plane node:
#kubeadm token list
#kubeadm token create
#
#If you don’t have the value of --discovery-token-ca-cert-hash, you can get it by running the following command chain on the control-plane node:
#openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'