#!/usr/bin/env bash
dnf_command() {
    local command=${1}
    local package_name=${2}
    dnf ${1} ${2} > /dev/null 2>&1
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
    arg=$1
    if [[ $(is_found $arg) == "False" || \
    $(is_installed $arg) == "False" || \
    $(can_update $arg) == "True" ]]; then
        echo "True"
    else
        echo "$arg already installed" 1>&2
    fi
}

if [[ $(should_install_dnf code) == "True" ]]; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
fi
if [[ $(should_install_command k3s) == "True" ]]; then
    sudo mkdir -p /etc/rancher/k3s/
    sudo chmod -R 777 /etc/rancher
    cp k3s/config.yaml /etc/rancher/k3s/
    sudo swapoff -a
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" INSTALL_K3S_SKIP_ENABLE=true sh -s - server
fi
if [[ $(should_install_command helm) == "True" ]]; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
if [[ $(should_install_dnf rpmfusion-free-release) == "True" ]]; then
    sudo dnf -y install \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
fi