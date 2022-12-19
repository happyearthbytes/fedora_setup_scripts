#!/usr/bin/env bash

kubectl apply -f k3s/nvidia-namespace.yaml


kubectl create cm -n nvidia-device-plugin nvidia-plugin-configs \
    --from-file=config=k3s/nvidia-config.yaml

kubectl apply -f k3s/nvidia-helm.yaml

label_filter="owner=joe"
node_name=$(kubectl get nodes -l ${label_filter} --no-headers=true -o custom-columns=NAME:.metadata.name)
kubectl label node --overwrite ${node_name} nvidia.com/device-plugin.config=nvidia-plugin-configs


# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#step-0-pre-requisites

# 2022/12/19 07:04:53 Detected non-NVML platform: could not load NVML: libnvidia-ml.so.1: cannot open shared object file: No such file or directory
# 2022/12/19 07:04:53 Detected non-Tegra platform: /sys/devices/soc0/family file not found
# 2022/12/19 07:04:53 Incompatible platform detected
# 2022/12/19 07:04:53 If this is a GPU node, did you configure the NVIDIA Container Toolkit?
# 2022/12/19 07:04:53 You can check the prerequisites at: https://github.com/NVIDIA/k8s-device-plugin#prerequisites
# 2022/12/19 07:04:53 You can learn how to set the runtime at: https://github.com/NVIDIA/k8s-device-plugin#quick-start
# 2022/12/19 07:04:53 If this is not a GPU node, you should set up a toleration or nodeSelector to only deploy this plugin on GPU nodes
# 2022/12/19 07:04:53 Error: error starting plugins: error getting plugins: unable to load resource managers to manage plugin devices: platform detection failed





# helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
# helm repo update
# plugin_version=$(helm search repo nvdp --devel | awk '{print $2}' | tail -1)
# helm upgrade -i nvdp nvdp/nvidia-device-plugin \
#   --namespace nvidia-device-plugin \
#   --create-namespace \
#   --version ${plugin_version} \
#   --set config.default=nvidia-plugin-configs \
#   --set config.name=nvidia-plugin-configs

# kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.14/cluster/addons/device-plugins/nvidia-gpu/daemonset.yaml








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
