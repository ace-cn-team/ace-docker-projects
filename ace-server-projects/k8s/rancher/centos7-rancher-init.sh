#!/bin/bash
# centos7 安装 k8s v1.18.2 master节点脚本
# https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
# https://my.oschina.net/u/572987/blog/3025730
#
#
## 载入公钥
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
## 安装 ELRepo 最新版本
yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
## 列出可以使用的 kernel 包版本
#yum list available --disablerepo=* --enablerepo=elrepo-kernel
## 安装指定的 kernel 版本：
yum install -y kernel-lt-4.4.220-1.el7.elrepo --enablerepo=elrepo-kernel
## 查看系统可用内核
cat /boot/grub2/grub.cfg | grep menuentry
## 设置开机从新内核启动
grub2-set-default "CentOS Linux (4.4.220-1.el7.elrepo.x86_64) 7 (Core)"
## 查看内核启动项
grub2-editenv list
#saved_entry=CentOS Linux (4.4.218-1.el7.elrepo.x86_64) 7 (Core)
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
#yum install -y dnf
#dnf install -y https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.13-3.1.el7.x86_64.rpm
#dnf install -y docker-ce
# yum list docker-ce --showduplicates | sort -r
yum -y install docker-ce-19.03.3-3.el7

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
systemctl daemon-reload
systemctl restart docker
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
# 开启IPVS服务
yum -y install ipvsadm  ipset
# 永久生效
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
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
#
#
# 查询指定版本 yum list kubelet --showduplicates | sort -r
# 自动安装kubeadm kubelet kubectl
yum install -y kubeadm-1.17.5-0
# 安装shell命令自动补全功能clu
yum install bash-completion -y
echo "source <(kubectl completion bash)" >> ~/.bashrc
systemctl enable kubelet
systemctl start kubelet
#
# 下载RKE工具
wget https://github.com/rancher/rke/releases/download/v1.0.7/rke_linux-arm64
mv rke_linux-amd64 /usr/bin/rke
rke up --config ./rancher-cluster.yml
export KUBECONFIG=$(pwd)/kube_config_rancher-cluster.yaml
#
## 每个节点都需要执行下列命令 start
# ssh免密登陆：https://blog.csdn.net/csdn_duomaomaso/article/details/79164073
#
# 添加操作用户rancher,原因：centos系统不能直接使用root账号
useradd rancher
passwd rancher
# 使用rancher账号操作docker
usermod -aG docker rancher
## 每个节点都需要执行下列命令 end
#
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
# 安装 cert-manager Helm chart
helm install \
 cert-manager jetstack/cert-manager \
 --namespace cert-manager \
 --version v0.12.0
helm install rancher rancher-stable/rancher \
 --namespace cattle-system \
 --set hostname=rancher.ace.com \
 --version 2.3.6
