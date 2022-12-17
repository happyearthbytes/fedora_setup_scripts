#!/usr/bin/env bash

kubectl create cm -n nvidia-device-plugin nvidia-plugin-configs \
    --from-file=config=nvidia-config.yaml

# TODO : kubectl apply -f helm.yaml
label_filter="owner=joe"
node_name=$(kubectl get nodes -l ${label_filter} --no-headers=true -o custom-columns=NAME:.metadata.name)
kubectl label node --overwrite ${node_name} nvidia.com/device-plugin.config=nvidia-plugin-configs

helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update
plugin_version=$(helm search repo nvdp --devel | awk '{print $2}' | tail -1)
helm upgrade -i nvdp nvdp/nvidia-device-plugin \
  --namespace nvidia-device-plugin \
  --create-namespace \
  --version ${plugin_version} \
  --set config.default=nvidia-plugin-configs \
  --set config.name=nvidia-plugin-configs

kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.14/cluster/addons/device-plugins/nvidia-gpu/daemonset.yaml

# https://github.com/NVIDIA/k8s-device-plugin#quick-start
# /etc/containerd/config.toml
# /var/lib/rancher/k3s/agent/etc/containerd/config.toml
# version = 2
# [plugins]
#   [plugins."io.containerd.grpc.v1.cri"]
#     [plugins."io.containerd.grpc.v1.cri".containerd]
#       default_runtime_name = "nvidia"

#       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
#         [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
#           privileged_without_host_devices = false
#           runtime_engine = ""
#           runtime_root = ""
#           runtime_type = "io.containerd.runc.v2"
#           [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
#             BinaryName = "/usr/bin/nvidia-container-runtime"


# kubectl create -f test.yaml
