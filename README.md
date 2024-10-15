# Kubernetes Cluster Setup with Docker on Ubuntu 20.04

This guide walks you through the process of setting up a Kubernetes cluster with Docker on Ubuntu. It consists of running four main scripts that automate the setup for Docker, Kubernetes, the master node, and worker nodes.

## Prerequisites

- **Operating System**: Ubuntu 20.04+ installed on both the master and worker nodes.
- **Access**: SSH access to both master and worker nodes.
- **Internet**: Ensure internet connectivity for installing required packages.
- **Networking**: Ensure network communication between the master and worker nodes within the same LAN.
- **Permissions**: Make the scripts executable before running them:
  ```bash
  chmod +x ./docker.sh ./k8s.sh ./master-deploy.sh ./worker-deploy.sh
  ```

## Installation Steps

### 1. Modify ip on each host

Before running the scripts, update the k8s.sh script to reflect the private IP addresses of your master and worker nodes.

```bash
vim k8s.sh
```
Modify `<master_ip>` and `<worker_ip>` in lines 26 and 27 to the respective private IP addresses of each node.

### 2. Run the Docker Installation Script

This script installs Docker on both **master** and **worker** nodes.  

**Command:**  

```bash
./docker.sh
```

**What it does:**  
- Updates the package lists
- Installs Docker
- Enables and starts the Docker service

### 3. Run the Kubernetes Installation Script

This script sets up Kubernetes on both **master** and **worker** nodes.  

**Command:**  
```bash
./k8s.sh
```

**What it does:**  
- Adds the Kubernetes package repository and installs kubeadm, kubelet, and kubectl
- Disables swap for Kubernetes compatibility
- Configures kernel modules and networking settings for Kubernetes

**Note:**  

After running this script, a reboot is recommended to apply changes:
```bash
reboot
```

### 4. Run the Master Node Deployment Script

This script configures the **master node** for the Kubernetes cluster.

**Command:**  

```bash
./master-deploy.sh
```
**What it does:**  

- Sets the hostname to master
- Configures Docker to use the systemd cgroup driver
- Initializes the Kubernetes cluster using kubeadm
- Installs Calico as the network plugin
- Provides the kubeadm join command for worker nodes to join the cluster

### 5. Run the Worker Node Deployment Script

This script configures the **worker nodes** to join the Kubernetes cluster.

**Command:**  

```bash
./worker-deploy.sh
```
**What it does:**  

- Sets the hostname to worker
- Prepares the worker node to join the Kubernetes cluster
- Join the worker node to the cluster

## References

[How to Install Kubernetes on Ubuntu 22.04](https://phoenixnap.com/kb/install-kubernetes-on-ubuntu)  
[Install Calico networking and network policy for on-premises deployments](https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises)  
[Troubleshooting and diagnostics](https://docs.tigera.io/calico/latest/operations/troubleshoot/troubleshooting#configure-networkmanager)
[Scheduling Pods on Master Nodes](https://medium.com/@shyamsandeep28/scheduling-pods-on-master-nodes-7e948f9cb02c)  
[Configuring each kubelet in your cluster using kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/kubelet-integration/)  
[K9S command not found after snap install](https://github.com/derailed/k9s/issues/2128)  
