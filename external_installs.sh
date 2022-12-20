#!/usr/bin/env bash
dnf_command() {
    local command=${1}
    local package_name=${2}
    dnf -y ${1} ${2} > /dev/null 2>&1
    rc=$?
    if [[ $rc == 0 ]]; then echo "True"; else echo "False"; fi
}

linux_command() {
    if ! command -v $1 &> /dev/null
    then
        echo "False"
    else
        echo "True"
    fi
}

can_run() { linux_command "$1"; }
is_found() { dnf_command "list" "$1"; }
can_update() { dnf_command "list --upgrades" "$1"; }
is_installed() { dnf_command "list --installed" "$1"; }
should_install_command() {
    arg=$1
    if [[ $(can_run $arg) == "False" ]]; then
        echo "True"
    else
        echo "$arg already installed" 1>&2
    fi
}
should_install_dnf() {
    local arg=$1
    local description="${2:-$arg}"
    if [[ $(is_found $arg) == "False" || \
    $(is_installed $arg) == "False" || \
    $(can_update $arg) == "True" ]]; then
        echo "True"
    else
        echo "$description already installed" 1>&2
    fi
}
add_line() {
  local line=$1
  local file=$2
  # Create the file if it doesn't exist
  [ -f $file ] || touch $file
  # add the line to the end of the file if it does not already exist
  grep -qxF "$line" $file || echo "$line" >> $file
}
add_bashrc() {
    add_line "$1" ~/.bashrc
}

service_running() {
    local service=$1
    systemctl is-active $service > /dev/null
    local status=$?
    if [[ "${status}" == "0" ]]; then
        echo "True"
    else
        echo "False"
    fi
}
if [[ $(should_install_dnf rpmfusion-free-release) == "True" ]]; then
    sudo dnf -y install \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
fi
if [[ $(should_install_dnf code vscode) == "True" ]]; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
fi
if [[ $(should_install_dnf nvidia-driver) == "True" ]]; then
    # sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

    # https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html
    sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora36/x86_64/cuda-fedora36.repo
    sudo dnf clean all
    sudo dnf -y module install --allowerasing nvidia-driver:latest-dkms
    sudo dnf -y install cuda
    add_bashrc "export PATH=/usr/local/cuda-12.0/bin${PATH:+:${PATH}}"

    # Note that the fedora37 repository does not exist at the time of writing this
    # sudo rpm --erase gpg-pubkey-7fa2af80*
    # source /etc/os-release
    # distro=${ID}${VERSION_ID}
    # sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/$distro/x86_64/cuda-$distro.repo
    # sudo dnf clean expire-cache
    # sudo dnf --disablerepo="rpmfusion-nonfree*" install cuda

    sudo systemctl enable nvidia-persistenced
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    sudo dracut --regenerate-all --force
    sudo reboot
fi
# Cuda test
# if [[ $(should_install_dnf nvidia-driver "cuda test") == "True" ]]; then
#     nvidia-smi
#     which nvidia-container-runtime
#     sudo dnf install -y freeglut-devel libX11-devel libXi-devel libXmu-devel make mesa-libGLU-devel freeimage-devel
#     git clone https://github.com/NVIDIA/cuda-samples.git
#     make -C cuda-samples/Samples/1_Utilities/deviceQuery
#     make -C cuda-samples/Samples/1_Utilities/bandwidthTest
#     cuda-samples/Samples/1_Utilities/deviceQuery/deviceQuery
#     cuda-samples/Samples/1_Utilities/bandwidthTest/bandwidthTest
# fi
if [[ $(should_install_dnf nvidia-container-toolkit) == "True" ]]; then
    # https://github.com/NVIDIA/k8s-device-plugin#quick-start
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

    distribution=$(. /etc/os-release;echo centos8) \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
    sudo dnf clean expire-cache
    sudo dnf install -y nvidia-container-toolkit
    distribution=$(. /etc/os-release;echo centos8) \
        && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
    # cat  /usr/share/containers/oci/hooks.d/oci-nvidia-hook.json

    sudo dnf install -y nvidia-container-runtime nvidia-modprobe

    # https://dischord.org/2022/06/14/rke2-and-nvidia-gpus-with-the-grid-operator/


# grep "nvidia-container-runtime" /var/lib/rancher/rke2/agent/etc/containerd/config.toml &>/dev/null && info "GPU containerd changes already applied" && exit 0
# awk '1;/plugins.cri.containerd]/{print "  default_runtime_name = \"nvidia-container-runtime\""}' /var/lib/rancher/rke2/agent/etc/containerd/config.toml > /var/lib/rancher/rke2/agent/etc/containerd/config.toml.tmpl
# echo -e '\n[plugins.linux]\n  runtime = "nvidia-container-runtime"' >> /var/lib/rancher/rke2/agent/etc/containerd/config.toml.tmpl
# echo -e '\n[plugins.cri.containerd.runtimes.nvidia-container-runtime]\n  runtime_type = "io.containerd.runc.v2"\n  [plugins.cri.containerd.runtimes.nvidia-container-runtime.options]\n    BinaryName = "nvidia-container-runtime"' >> /var/lib/rancher/rke2/agent/etc/containerd/config.toml.tmpl

# DOCKER_REGISTRY_URL=$(cat defaults.json | jq -er ".registries.docker.url")
# sed -i "s/REGISTRY_PLACEHOLDER/${DOCKER_REGISTRY_URL}/g" ./Infra_Installer/gpu_plugin/nvidia-device-plugin.yaml
# kubectl apply -f ./Infra_Installer/gpu_plugin/nvidia-device-plugin.yaml
# kubectl -n kube-system rollout restart daemonset nvidia-device-plugin-daemonset

# root@ubuntu:~# cat /var/lib/rancher/k3s/agent/etc/containerd/config.toml | grep -i nvidia
# [plugins.cri.containerd.runtimes."nvidia"]
# [plugins.cri.containerd.runtimes."nvidia".options]
#   BinaryName = "/usr/bin/nvidia-container-runtime"

# kubectl get runtimeclass
# kubectl describe node | grep gpu

fi
if [[ $(should_install_command helm) == "True" ]]; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
if [[ $(should_install_command k3s) == "True" ]]; then
    sudo mkdir -p /etc/rancher/k3s/
    sudo chmod -R 777 /etc/rancher
    cp k3s/config.yaml /etc/rancher/k3s/
    sudo swapoff -a
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" INSTALL_K3S_SKIP_ENABLE=true INSTALL_K3S_SKIP_START=true sh -s - server
    # INSTALL_K3S_VERSION="v1.23.7+k3s1" sh
fi
if [[ $(service_running k3s) == "False" ]]; then
    # Set defaults
    containerd config default | sudo tee /var/lib/rancher/k3s/agent/etc/containerd/config.toml 2>&1 > /dev/null
    containerd config default | sudo tee /etc/containerd/config.toml 2>&1 > /dev/null
    # Copy the template
    sudo cp k3s/config.toml.tmpl /var/lib/rancher/k3s/agent/etc/containerd/
    sudo cp k3s/config.toml.tmpl /etc/containerd/

    sudo systemctl start k3s
    sudo systemctl enable k3s
    sleep 1
    kubectl config view --raw > ~/.kube/config
    chmod 600 ~/.kube/config

    kubectl apply -f k3s/nvidia-namespace.yaml

    kubectl create cm -n nvidia-device-plugin nvidia-plugin-configs \
        --from-file=config=k3s/nvidia-config.yaml

    kubectl apply -f k3s/nvidia-helm.yaml

    label_filter="owner=joe"
    node_name=$(kubectl get nodes -l ${label_filter} --no-headers=true -o custom-columns=NAME:.metadata.name)
    kubectl label node --overwrite ${node_name} nvidia.com/device-plugin.config=nvidia-plugin-configs

# sleep 5
# kubectl -n kube-system create serviceaccount tiller
# kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
# helm init --service-account tiller

#    --write-kubeconfig value, -o value         (client) Write kubeconfig for admin client to this file [$K3S_KUBECONFIG_OUTPUT]
#    --kube-apiserver-arg value                 (flags) Customized flag for kube-apiserver process
#    --node-name value                          (agent/node) Node name [$K3S_NODE_NAME]
#    --container-runtime-endpoint value         (agent/runtime) Disable embedded containerd and use the CRI socket at the given path; when used with --docker this sets the docker socket path
#    --private-registry value                   (agent/runtime) Private registry configuration file (default: "/etc/rancher/k3s/registries.yaml")



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



fi


