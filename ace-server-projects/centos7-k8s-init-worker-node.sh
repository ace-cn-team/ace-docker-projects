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
#yum install -y dnf
#dnf install -y https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.13-3.1.el7.x86_64.rpm
#dnf install -y docker-ce
yum -y install docker-ce-18.03.1.ce-1.el7.centos
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
yum install -y kubeadm-1.18.2-0
# 安装shell命令自动补全功能clu
yum install bash-completion -y
echo "source <(kubectl completion bash)" >> ~/.bashrc
systemctl enable kubelet
systemctl start kubelet
#
# 把节点添加到master节点中
kubeadm join 172.1.0.1:6443 --token 8yy4dw.fswmd6pozfhc4vzk \
    --discovery-token-ca-cert-hash sha256:a1d5a11a2bd266194aa90691d24f2efb63f5558d7b7c728e1c0ef3a7832d4908
# 启动不成功，如果是网络问题，kubelet.go:2187] Container runtime network not ready: NetworkReady=false reaeady: cni config uninitialized
# scp -r 172.1.0.1:/etc/cni /etc
# scp 172.1.0.1:/opt/cni/bin/weave-plugin-2.6.2  ./
# scp 172.1.0.1:/opt/cni/bin/weave-ipam  ./
# scp 172.1.0.1:/opt/cni/bin/weave-net  ./
# scp 172.1.0.1://etc/kubernetes/admin.conf /etc/kubernetes/admin.conf
# 重启kubelet
# systemctl restart kubelet
# 回到master 节点查看 状态 仍然是notready （一般情况，重启服务，需要等他反应，好吧，我们等几分钟）
# 始终看不到 status  ready
# 回到 node节点
# 再次使用
# journalctl -f -u kubelet


