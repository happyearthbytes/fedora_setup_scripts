#!/usr/bin/env bash
packages=packages.txt
external=./external_installs.sh

print_install() {
    echo "# ==============================================================================="
    echo "# Installing: $1"
    echo "# ==============================================================================="
}

print_install "standard packages"
sudo dnf install -y $(cat $packages | tr '\n' ' ')
print_install "external packages"
${external}
print_install "extra setup"
extra_setup=./extra_setup.sh
${extra_setup}

print_install "k3s nvidia"
cd k3s/nvidia
./start.sh