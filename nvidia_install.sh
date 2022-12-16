#!/usr/bin/env bash
# sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

# https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html
sudo dnf install -y kernel-devel kernel-headers
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora36/x86_64/cuda-fedora36.repo
sudo dnf clean all
sudo dnf -y module install --allowerasing nvidia-driver:latest-dkms
sudo dnf -y install cuda

# Note that the fedora37 repository does not exist at the time of writing this
# sudo rpm --erase gpg-pubkey-7fa2af80*
# source /etc/os-release
# distro=${ID}${VERSION_ID}
# sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/$distro/x86_64/cuda-$distro.repo
# sudo dnf clean expire-cache
# sudo dnf --disablerepo="rpmfusion-nonfree*" install cuda

sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo reboot


export PATH=/usr/local/cuda-12.0/bin${PATH:+:${PATH}}

sudo systemctl enable nvidia-persistenced

mkdir -p ~/repos
cd ~/repos
git clone https://github.com/NVIDIA/cuda-samples.git
make -C cuda-samples/Samples/1_Utilities/deviceQuery
make -C cuda-samples/Samples/1_Utilities/bandwidthTest

cuda-samples/Samples/1_Utilities/deviceQuery/deviceQuery
cuda-samples/Samples/1_Utilities/bandwidthTest/bandwidthTest

sudo dnf install -y freeglut-devel libX11-devel libXi-devel libXmu-devel make mesa-libGLU-devel freeimage-devel


# #echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf

# blacklist nouveau
# options nouveau modeset=0

# sudo nano /etc/default/grub
# GRUB_CMDLINE_LINUX="......... rd.driver.blacklist=nouveau"

# Append ‘rd.driver.blacklist=nouveau’ (and ‘nvidia-drm.modeset=1’) to end of ‘GRUB_CMDLINE_LINUX=”…”‘.


# sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# sudo dnf remove xorg-x11-drv-nouveau

# sudo dracut --force /boot/initramfs-$(uname -r).img $(uname -r)
# # -or- ?
# # dnf install --skip-broken $(for i in $(dnf repoquery --installed kernel\* --qf '%{name}'); do echo $i-$(dnf --quiet --disablerepo=* --enablerepo=inttf repoquery --queryformat '%{version}-%{release}' kernel |sort -V |tail -1); done)


# mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img
# dracut /boot/initramfs-$(uname -r).img $(uname -r)




# systemctl set-default multi-user.target

# sudo reboot

# # sudo bash NVIDIA-Linux-x86_64-470.74.run
# # 4. Select Yes to install Nvidia's 32-bit compatibility libraries:
# # 5. Select Yes to allow automatic Xorg backup:

# systemctl set-default graphical.target


# dnf install vdpauinfo libva-vdpau-driver libva-utils


