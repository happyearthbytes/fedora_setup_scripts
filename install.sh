#!/usr/bin/env bash
packages=packages.txt
external=./external_installs.sh
extra_packages=extra_packages.txt
extra_external=./extra_external_installs.sh

nvidia_packages=nvidia_install.sh


sudo dnf install -y $(cat $packages | tr '\n' ' ')
${external}
sudo dnf install -y $(cat $extra_packages | tr '\n' ' ')

extra_setup=./extra_setup.sh
${extra_setup}

nvidia_packages=./nvidia_install.sh
# ${nvidia_install.sh}


cd k3s
./start.sh

cd nvidia
./start.sh