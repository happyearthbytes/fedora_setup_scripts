#!/usr/bin/env bash

timedatectl set-local-rtc 1

sudo modprobe overlay
sudo modprobe br_netfilter
sudo modprobe ipmi_devintf

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# overwrite config.toml
# sudo mkdir -p /etc/containerd \
#     && sudo containerd config default | sudo tee /etc/containerd/config.toml

# To make use of the NVIDIA Container Runtime, additional configuration is required. The following options should be added to configure nvidia as a runtime and use systemd as the cgroup driver. A patch is provided below:

# cat <<EOF > containerd-config.patch
# --- config.toml.orig    2020-12-18 18:21:41.884984894 +0000
# +++ /etc/containerd/config.toml 2020-12-18 18:23:38.137796223 +0000
# @@ -94,6 +94,15 @@
#         privileged_without_host_devices = false
#         base_runtime_spec = ""
#         [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
# +            SystemdCgroup = true
# +       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
# +          privileged_without_host_devices = false
# +          runtime_engine = ""
# +          runtime_root = ""
# +          runtime_type = "io.containerd.runc.v1"
# +          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
# +            BinaryName = "/usr/bin/nvidia-container-runtime"
# +            SystemdCgroup = true
#     [plugins."io.containerd.grpc.v1.cri".cni]
#     bin_dir = "/opt/cni/bin"
#     conf_dir = "/etc/cni/net.d"
# EOF
# After apply the configuration patch, restart containerd:

# sudo systemctl restart containerd


# sudo systemctl start containerd
# sudo systemctl enable containerd
