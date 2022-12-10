#!/usr/bin/env bash
dnf_command() {
    local command=${1}
    local package_name=${2}
    dnf ${1} ${2} > /dev/null 2>&1
    rc=$?
    if [[ $rc == 0 ]]; then echo "True"; else echo "False"; fi
}
is_found() { dnf_command "list" "$1"; }
can_update() { dnf_command "list --upgrades" "$1"; }
is_installed() { dnf_command "list --installed" "$1"; }
should_install() {
    arg=$1
    if [[ $(is_found $arg) == "False" || \
    $(is_installed $arg) == "False" || \
    $(can_update $arg) == "True" ]]; then
        echo "True"
    else
        echo "$arg already installed" 1>&2
    fi
}

if [[ $(should_install code) == "True" ]]; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
fi
if [[ $(should_install k3s-selinux) == "True" ]]; then
    sudo mkdir -p /etc/rancher/k3s/
    sudo chmod -R 777 /etc/rancher
    cp k3s/config.yaml /etc/rancher/k3s/
    curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_ENABLE=true sh -s - server
fi
if [[ $(should_install rpmfusion-free-release) == "True" ]]; then
    sudo dnf -y install \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
fi