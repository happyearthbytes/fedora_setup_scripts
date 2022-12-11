#!/usr/bin/env bash
packages=packages.txt
external=./external_installs.sh
extra_packages=extra_packages.txt
extra_external=./extra_external_installs.sh

sudo dnf install -y $(cat $packages | tr '\n' ' ')
${external}
sudo dnf install -y $(cat $extra_packages | tr '\n' ' ')