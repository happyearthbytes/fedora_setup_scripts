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


# https://github.com/NVIDIA/k8s-device-plugin#quick-start
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

distribution=$(. /etc/os-release;echo centos8) \
   && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
sudo dnf clean expire-cache \
    && sudo dnf install -y nvidia-container-toolkit
distribution=$(. /etc/os-release;echo centos8) \
    && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
cat  /usr/share/containers/oci/hooks.d/oci-nvidia-hook.json

sudo dnf install -y nvidia-container-runtime nvidia-modprobe

# https://dev.to/mweibel/add-nvidia-gpu-support-to-k3s-with-containerd-4j17
# /sbin/modprobe nvidia
# if [ "$?" -eq 0 ]; then
#   # Count the number of NVIDIA controllers found.
#   NVDEVS=`lspci | grep -i NVIDIA`
#   N3D=`echo "$NVDEVS" | grep "3D controller" | wc -l`
#   NVGA=`echo "$NVDEVS" | grep "VGA compatible controller" | wc -l`
#   N=`expr $N3D + $NVGA - 1`
#   for i in `seq 0 $N`; do
#     mknod -m 666 /dev/nvidia$i c 195 $i
#   done
#   mknod -m 666 /dev/nvidiactl c 195 255
# else
#   exit 1
# fi
# /sbin/modprobe nvidia-uvm
# if [ "$?" -eq 0 ]; then
#   # Find out the major device number used by the nvidia-uvm driver
#   D=`grep nvidia-uvm /proc/devices | awk '{print $1}'`
#   mknod -m 666 /dev/nvidia-uvm c $D 0
# else
#   exit 1
# fi




sudo dracut --regenerate-all --force
sudo reboot

podman run --rm --security-opt=label=disable \
     --hooks-dir=/usr/share/containers/oci/hooks.d/ \
     nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi

