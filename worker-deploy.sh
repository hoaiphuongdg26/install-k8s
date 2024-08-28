#!/bin/bash
set -ex

sudo hostnamectl set-hostname worker
sudo systemctl stop apparmor && sudo systemctl disable apparmor
sudo systemctl restart containerd.service
echo "Worker node setup complete. Please join this node to the Kubernetes cluster using the kubeadm join command provided by the master node."