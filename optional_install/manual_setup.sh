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


# Configure podman to use a mounted volume
# sudo sed -i -e '/graphroot =/ s|\(.*=\)\(.*\)|\1 "/media/ContainerStorage/storage"|' /etc/containers/storage.conf
# mkdir -p /home/joe/.config/containers
# cp /etc/containers/storage.conf /home/${USER}/.config/containers/storage.conf
# sudo semanage fcontext -a -t container_file_t /media/ContainerStorage/storage
# restorecon -R -v /media/ContainerStorage/storage



# /etc/fstab
# LABEL=SharedData /media/SharedData ntfs-3g rw,uid=1000,gid=1000,fmask=0002,dmask=0003 0 0
# LABEL=SharedMedia /media/SharedMedia ntfs-3g rw,uid=1000,gid=1000,fmask=0002,dmask=0003 0 0
# LABEL=ContainerStorage /media/ContainerStorage ext4 default 0 0
# LABEL=BackupData /media/BackupData ntfs-3g rw,uid=1000,gid=1000,fmask=0002,dmask=0003 0 0
# LABEL=WindowsOS /media/WindowsOS ntfs-3g rw,auto,user,fmask=0002,dmask=0003 0 0