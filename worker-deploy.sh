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
sudo hostnamectl set-hostname worker01-node
sudo touch /etc/hosts
echo "10.0.0.4 master-node" | sudo tee -a /etc/hosts
echo "10.0.0.5 worker01-node" | sudo tee -a /etc/hosts
echo "10.0.0.6 worker02-node" | sudo tee -a /etc/hosts

mkdir -p /etc/systemd/system/kubelet.service.d/
sudo touch /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo cp /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo sed -i "5i Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload && sudo systemctl restart kubelet

sudo systemctl stop apparmor && sudo systemctl disable apparmor
sudo systemctl restart containerd.service
echo "Worker node setup complete. Please join this node to the Kubernetes cluster using the kubeadm join command provided by the master node."