#!/bin/bash
set -ex
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo touch /etc/modules-load.d/containerd.conf
echo "overlay" | sudo tee -a /etc/modules-load.d/containerd.conf
echo "br_netfilter" | sudo tee -a /etc/modules-load.d/containerd.conf
sudo modprobe overlay
sudo modprobe br_netfilter
sudo touch /etc/sysctl.d/kubernetes.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/kubernetes.conf
echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.d/kubernetes.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/kubernetes.conf
sudo sysctl --system
sudo hostnamectl set-hostname master-node
sudo touch /etc/hosts
echo "10.0.0.4 master-node" | sudo tee -a /etc/hosts
echo "10.0.0.5 worker01-node" | sudo tee -a /etc/hosts
echo "10.0.0.6 worker01-node" | sudo tee -a /etc/hosts

mkdir -p /etc/systemd/system/kubelet.service.d/
sudo touch /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo cp /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo sed -i "5i Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload && sudo systemctl restart kubelet
sudo kubeadm init \
--apiserver-advertise-address=10.0.0.4 \
--apiserver-bind-port=6443 \
--pod-network-cidr=192.168.0.0/16 \
--service-cidr=10.96.0.0/12 \
--service-dns-domain=cluster.local
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo snap install k9s
sudo ln -s /snap/k9s/current/bin/k9s /snap/bin/

sudo touch /etc/NetworkManager/conf.d/calico.conf
echo "[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:vxlan-v6.calico;interface-name:wireguard.cali;interface-name:wg-v6.cali" | sudo tee -a /etc/NetworkManager/conf.d/calico.conf
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

sudo kubeadm token create --print-join-command
echo "Kubernetes master node setup complete. Please NOTE the kubeadm join command provided by the master node."