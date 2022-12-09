#!/usr/bin/env bash
install_file=packages.txt
sudo dnf install -y $(cat $install_file | tr '\n' ' ')
./additional_installs.sh

