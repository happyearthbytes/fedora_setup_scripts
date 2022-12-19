#!/usr/bin/env bash
# SSH
ssh-keygen -t rsa -C "joe.dipilato@fedora.pc"
cat ~/.ssh/id_rsa.pub

# GIT
git config --global user.email "joe.dipilato@fedora.pc"
git config --global user.name "joe.dipilato"

# DOWNLOAD
urls=url_download.txt
for url in $(cat $urls); do
    wget --content-disposition -P ~/Downloads $url -nv
done
