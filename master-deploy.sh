#!/bin/bash
set -ex
echo "KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs"" | sudo tee -a /etc/default/kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
sudo touch /etc/docker/daemon.json
sudo bash -c "cat >> /etc/docker/daemon.json" <<EOL
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOL
sudo systemctl daemon-reload && sudo systemctl restart docker
mkdir -p /etc/systemd/system/kubelet.service.d/
sudo touch /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo cp /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo sed -i "5i Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload && sudo systemctl restart kubelet
sudo kubeadm init --control-plane-endpoint=master --upload-certs
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo snap install k9s
sudo ln -s /snap/k9s/current/bin/k9s /snap/bin/

#sudo touch /etc/NetworkManager/conf.d/calico.conf
#echo "[keyfile]
#unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:vxlan-v6.calico;interface-name:wireguard.cali;interface-name:wg-v6.cali" | sudo tee -a /etc/NetworkManager/conf.d/calico.conf
#kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl taint nodes --all node-role.kubernetes.io/control-plane-Copied!

sudo kubeadm token create --print-join-command
echo "Kubernetes master node setup complete. Please NOTE the kubeadm join command provided by the master node."