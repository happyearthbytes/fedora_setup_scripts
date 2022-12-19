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
    local description="${$2:-${arg}}"
    if [[ $(is_found $arg) == "False" || \
    $(is_installed $arg) == "False" || \
    $(can_update $arg) == "True" ]]; then
        echo "True"
    else
        echo "$arg already installed" 1>&2
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

if [[ $(should_install_dnf rpmfusion-free-release) == "True" ]]; then
    sudo dnf -y install \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
fi
if [[ $(should_install_dnf code) == "True" ]]; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
fi
if [[ $(should_install_dnf nvidia-driver) == "True" ]]; then
    # sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

    # https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html
    sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora36/x86_64/cuda-fedora36.repo
    sudo dnf clean all
    sudo dnf -y module install --allowerasing nvidia6a-driver:latest-dkms
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
if [[ $(should_install_dnf nvidia-driver) == "True" ]]; then
    sudo dnf install -y freeglut-devel libX11-devel libXi-devel libXmu-devel make mesa-libGLU-devel freeimage-devel
    git clone https://github.com/NVIDIA/cuda-samples.git
    make -C cuda-samples/Samples/1_Utilities/deviceQuery
    make -C cuda-samples/Samples/1_Utilities/bandwidthTest
    cuda-samples/Samples/1_Utilities/deviceQuery/deviceQuery
    cuda-samples/Samples/1_Utilities/bandwidthTest/bandwidthTest
fi
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
fi

if [[ $(should_install_command k3s) == "True" ]]; then
    sudo mkdir -p /etc/rancher/k3s/
    sudo chmod -R 777 /etc/rancher
    cp k3s/config.yaml /etc/rancher/k3s/
    sudo swapoff -a
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" INSTALL_K3S_SKIP_ENABLE=true INSTALL_K3S_SKIP_START=true sh -s - server
fi
if [[ $(should_install_command helm) == "True" ]]; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

