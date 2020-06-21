#!/bin/bash
# centos7 安装 k8s v1.18.2 master节点脚本
# https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
#
#
## 载入公钥
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
## 安装 ELRepo 最新版本
yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
## 列出可以使用的 kernel 包版本
#yum list available --disablerepo=* --enablerepo=elrepo-kernel
## 安装指定的 kernel 版本：
yum install -y kernel-lt-4.4.227-1.el7.elrepo --enablerepo=elrepo-kernel
## 查看系统可用内核
cat /boot/grub2/grub.cfg | grep menuentry
## 设置开机从新内核启动
grub2-set-default "CentOS Linux (4.4.227-1.el7.elrepo.x86_64) 7 (Core)"
## 查看内核启动项
grub2-editenv list
#saved_entry=CentOS Linux (4.4.218-1.el7.elrepo.x86_64) 7 (Core)
# 查看所有内核
rpm -qa |grep kernel
# 删除无用内核
#
#
# 禁用firewall
systemctl stop firewalld.service & \
systemctl disable firewalld.service
#
# 安装iptables
yum install -y iptables-services & \
#systemctl enable iptables & \
#systemctl start iptables
systemctl stop iptables.service && systemctl disable iptables.service
#
# 确保 iptables 工具不使用 nftables 后端,
# https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#%E7%A1%AE%E4%BF%9D-iptables-%E5%B7%A5%E5%85%B7%E4%B8%8D%E4%BD%BF%E7%94%A8-nftables-%E5%90%8E%E7%AB%AF
update-alternatives --set iptables /usr/sbin/iptables-legacy
#
# 安装docker
# yum -y install yum-utils
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
#yum install -y dnf
#dnf install -y https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.13-3.1.el7.x86_64.rpm
#dnf install -y docker-ce
# yum list docker-ce --showduplicates | sort -r
yum -y install docker-ce-19.03.3-3.el7

# Setup daemon.
mkdir -p /etc/docker
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
systemctl daemon-reload & \
systemctl restart docker & \
systemctl enable docker.service & \
systemctl start docker.service
#
# 设置转发
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
#
# 关闭swap,k8s安装限制
#第二步修改配置文件 -
# vim /etc/fstab
#删除swap相关行 /mnt/swap swap swap defaults 0 0 这一行或者注释掉这一行
echo "vm.swappiness = 0">> /etc/sysctl.conf
swapoff -a & \
sysctl -p
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
docker pull gotok8s/kube-apiserver:v1.18.2 && \
docker pull gotok8s/kube-controller-manager:v1.18.2 && \
docker pull gotok8s/kube-scheduler:v1.18.2 && \
docker pull gotok8s/kube-proxy:v1.18.2 && \
docker pull gotok8s/pause:3.2 &&\
docker pull gotok8s/etcd:3.4.3-0 &&\
docker pull gotok8s/coredns:1.6.7
# 重命名
docker tag docker.io/gotok8s/kube-apiserver:v1.18.2 k8s.gcr.io/kube-apiserver:v1.18.2 && \
docker tag docker.io/gotok8s/kube-controller-manager:v1.18.2 k8s.gcr.io/kube-controller-manager:v1.18.2 && \
docker tag docker.io/gotok8s/kube-scheduler:v1.18.2 k8s.gcr.io/kube-scheduler:v1.18.2 && \
docker tag docker.io/gotok8s/kube-proxy:v1.18.2 k8s.gcr.io/kube-proxy:v1.18.2 && \
docker tag docker.io/gotok8s/pause:3.2 k8s.gcr.io/pause:3.2 && \
docker tag docker.io/gotok8s/etcd:3.4.3-0 k8s.gcr.io/etcd:3.4.3-0 && \
docker tag docker.io/gotok8s/coredns:1.6.7 k8s.gcr.io/coredns:1.6.7
#
#
#
# 查询指定版本 yum list kubelet --showduplicates | sort -r
# 自动安装kubeadm kubelet kubectl
yum install -y kubeadm-1.18.4-0 && \
# 安装shell命令自动补全功能clu
yum install bash-completion -y && \
source /usr/share/bash-completion/bash_completion && \
source <(kubectl completion bash) && \
echo "source <(kubectl completion bash)" >> ~/.bashrc && \
systemctl enable kubelet && \
systemctl start kubelet
##
# 更改节点的IP地址
# vim /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml --node-ip=172.1.1.2"
# systemctl daemon-reload && systemctl restart kubelet
#
# https://kubernetes.io/zh/docs/reference/setup-tools/kubeadm/kubeadm-init/
kubeadm init \
--apiserver-advertise-address=172.1.1.2 \
--apiserver-bind-port=6443 \
--pod-network-cidr=11.8.0.0/16
#--service-cidr 10.96.0.0/16

# kubeadm init 参数
# --apiserver-advertise-address string
#   API 服务器所公布的其正在监听的 IP 地址。如果未设置，则使用默认网络接口。
# --apiserver-bind-port int32     默认值：6443
#   API 服务器绑定的端口。
# --apiserver-cert-extra-sans stringSlice
#   用于 API Server 服务证书的可选附加主题备用名称（SAN）。可以是 IP 地址和 DNS 名称。
# --cert-dir string     默认值："/etc/kubernetes/pki"
#   保存和存储证书的路径。
# --certificate-key string
#   用于加密 kubeadm-certs Secret 中的控制平面证书的密钥。
# --config string
#   kubeadm 配置文件的路径。
# --control-plane-endpoint string
#   为控制平面指定一个稳定的 IP 地址或 DNS 名称。
# --cri-socket string
#   要连接的 CRI 套接字的路径。如果为空，则 kubeadm 将尝试自动检测此值；仅当安装了多个 CRI 或具有非标准 CRI 插槽时，才使用此选项。
# --dry-run
#   不要应用任何更改；只是输出将要执行的操作。
# -k, --experimental-kustomize string
#   用于存储 kustomize 为静态 pod 清单所提供的补丁的路径。
# --feature-gates string
#   一组用来描述各种功能特性的键值（key=value）对。选项是：
#   IPv6DualStack=true|false (ALPHA - default=false)
# -h, --help
#   init 操作的帮助命令
# --ignore-preflight-errors stringSlice
#   错误将显示为警告的检查列表；例如：'IsPrivilegedUser,Swap'。取值为 'all' 时将忽略检查中的所有错误。
# --image-repository string     默认值："k8s.gcr.io"
#   选择用于拉取控制平面镜像的容器仓库
# --kubernetes-version string     默认值："stable-1"
#   为控制平面选择一个特定的 Kubernetes 版本。
# --node-name string
#   指定节点的名称。
# --pod-network-cidr string
#   指明 pod 网络可以使用的 IP 地址段。如果设置了这个参数，控制平面将会为每一个节点自动分配 CIDRs。
# --service-cidr string     默认值："10.96.0.0/12"
#   为服务的虚拟 IP 地址另外指定 IP 地址段
# --service-dns-domain string     默认值："cluster.local"
#   为服务另外指定域名，例如："myorg.internal"。
# --skip-certificate-key-print
#   不要打印用于加密控制平面证书的密钥。
# --skip-phases stringSlice
#   要跳过的阶段列表
# --skip-token-print
#   跳过打印 'kubeadm init' 生成的默认引导令牌。
# --token string
#   这个令牌用于建立控制平面节点与工作节点间的双向通信。格式为 [a-z0-9]{6}\.[a-z0-9]{16} - 示例：abcdef.0123456789abcdef
# --token-ttl duration     默认值：24h0m0s
#   令牌被自动删除之前的持续时间（例如 1 s，2 m，3 h）。如果设置为 '0'，则令牌将永不过期
# --upload-certs
#   将控制平面证书上传到 kubeadm-certs Secret。
#
#
#
# root user run this
export KUBECONFIG=/etc/kubernetes/admin.conf
# 使用IPVS,mode字段修改为"ipvs"
kubectl edit configmap kube-proxy -n kube-system
# 配置IPVS模式之后，删除之前所有的kube-proxy pod,重新启动
#-
#
# 安装 k8s weave网络管理插件（有其它网络插件选择）。创建时间比较长
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# Please follow the steps to install Kubernetes cluster with Kubeadm,
# however must specify --pod-network-cidr when you run kubeadm init.
# Kube-router relies on kube-controller-manager to allocate pod CIDR for the nodes.
# Kube-router provides pod networking, network policy and high perfoming IPVS/LVS based service proxy.
# Depending on you choose to use kube-router for service proxy you have two options.
#
# 以下两种部署方式任选其一
#
# 1. 只启用 pod网络通信，网络隔离策略 功能
#
# kubectl apply -f /ace/kubeadm-kuberouter.yaml
kubectl apply -f https://raw.githubusercontent.com/ace-cn-team/ace-docker-projects/master/ace-server-projects/kubeadm-kuberouter.yaml
#
# 2. 启用 pod网络通信，网络隔离策略，服务代理 所有功能
# 删除kube-proxy和其之前配置的服务代理
kubectl get pods -n kube-system -l k8s-app=kube-proxy | grep kube-proxy | awk '{print $1}' | xargs kubectl delete pod -n kube-system
kubectl get pods -n kube-system -l k8s-app=kube-proxy | grep kube-proxy | awk '{print $1}' | xargs kubectl delete pod -n kube-system
#kubectl apply -f kubeadm-kuberouter-all-features.yaml
#kubectl -n kube-system delete ds kube-proxy
# 在每个节点上执行
#docker run --privileged --net=host registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy-amd64:v1.10.2 kube-proxy --cleanup
# 查看
kubectl get svc --all-namespaces
# 检查网络是否创建成功
kubectl get pods --all-namespaces -o wide
kubectl get nodes --all-namespaces -o wide
#
#
#
# 在文档 /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# [Service]中添加参数
# Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice"
#
# 在/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf 配置集群节点IP地址 --node-ip
# 添加参数之后，重新加载kubelet
# systemctl daemon-reload
# systemctl restart kubelet
# 开启单机集群模式，默认关闭
# kubectl taint nodes --all node-role.kubernetes.io/master-
# master 不参与POD负载
# kubectl taint nodes k8s-master-1 node-role.kubernetes.io/master=:NoSchedule
#
# 添加worker节点
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#join-nodes
#
# If you do not have the token, you can get it by running the following command on the control-plane node:
# kubeadm token list
# kubeadm token create
#
# If you don’t have the value of --discovery-token-ca-cert-hash, you can get it by running the following command chain on the control-plane node:
# openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
#
# 卸载
# kubeadm reset -f && yum remove -y kubeadm.x86_64 kubectl.x86_64 kubectl.x86_64 kubernetes-cni.x86_64
# journalctl -f -u kubelet
#
# 检查内部网络
# kubectl run busybox --rm=true --image=busybox --restart=Never -it


#
#
#
#
kubeadm join 172.1.1.2:6443 --token i0imoi.88vyvbhndwyir79o \
    --discovery-token-ca-cert-hash sha256:0beae5ecb66df59390b7b8778e7ae8656044d2a14d33494c016aceb834652ec3
#