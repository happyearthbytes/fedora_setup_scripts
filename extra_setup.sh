#!/usr/bin/env bash
add_line() {
  local line=$1
  local file=$2
  [ -f $file ] || touch $file
  grep -qxF "$line" $file || echo "$line" | sudo tee -a $file
}

setup_bashrc() {
  echo "not implemented"
}

set_clock() {
  timedatectl set-local-rtc 1
}

setup_containerd() {
  sudo modprobe overlay
  sudo modprobe br_netfilter
  sudo modprobe ipmi_devintf

  cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
  overlay
  br_netfilter
EOF

  cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
  net.bridge.bridge-nf-call-iptables  = 1
  net.ipv4.ip_forward                 = 1
  net.bridge.bridge-nf-call-ip6tables = 1
EOF

  sudo sysctl --system > /dev/null
}

setup_hosts() {
  # TODO
  # /etc/hosts
  # 127.0.0.1 whoami.themachine.pc whoami
  # 127.0.0.1 traefik.themachine.pc traefik
  add_line '127.0.0.1 registry.themachine.pc registry' /etc/hosts
  # add_line '192.168.1.192 registry.themachine.k3s registry' /etc/hosts
}

setup_registry_links() {
  add_line "[[registry]]" /etc/containers/registries.conf
  add_line 'location="registry"' /etc/containers/registries.conf
  add_line 'insecure=true' /etc/containers/registries.conf
}

start_registry() {
  kubectl apply -f k3s/registry-helm.yml
}


start_services() {
  sudo systemctl start etcd
  sudo systemctl enable etcd
  sudo systemctl start systemd-networkd
  sudo systemctl enable systemd-networkd
  sudo systemctl start sshd
  sudo systemctl enable sshd
  sudo systemctl start NetworkManager
  sudo systemctl enable NetworkManager
  # sudo systemctl start systemd-boot-check-no-failures
  # sudo systemctl enable systemd-boot-check-no-failures
  # sudo systemctl start nginx
  # sudo systemctl enable nginx
}



other() {
  echo other
  # sudo chown ${USER} /media/ContainerStorage/storage/overlay/l
  # sudo chown ${USER} /run/user/$(id -u)/overlay
  # podman kube play  -q k3s/container-registry.yml || true
  # sudo systemctl restart podman
  # TODO
  # /etc/nginx/nginx.conf
  # TODO
  # update unqualified-search-registries = ["registry.fedoraproject.org", "registry.access.redhat.com", "docker.io", "quay.io"]
  # update unqualified-search-registries = ["themachine.home:5000", "registry.fedoraproject.org", "registry.access.redhat.com", "docker.io", "quay.io"]
  # systemctl list-unit-files
  # systemctl list-units -a

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

  # grub2-mkconfig -o /boot/grub2/grub.cfg
  # grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  # https://rootlesscontaine.rs/getting-started/common/cgroup2/
  # To boot the host with cgroup v2, add the following string to the GRUB_CMDLINE_LINUX line in /etc/default/grub and then run sudo update-grub.
  # systemd.unified_cgroup_hierarchy=1

  # overwrite config.toml
  # sudo mkdir -p /etc/containerd \
  #     && sudo containerd config default | sudo tee /etc/containerd/config.toml

  # https://dev.to/mweibel/add-nvidia-gpu-support-to-k3s-with-containerd-4j17
  # To make use of the NVIDIA Container Runtime, additional configuration is required. The following options should be added to configure nvidia as a runtime and use systemd as the cgroup driver. A patch is provided below:

  # cat <<EOF > containerd-config.patch
  # --- config.toml.orig    2020-12-18 18:21:41.884984894 +0000
  # +++ /etc/containerd/config.toml 2020-12-18 18:23:38.137796223 +0000
  # @@ -94,6 +94,15 @@
  #         privileged_without_host_devices = false
  #         base_runtime_spec = ""
  #         [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  # +            SystemdCgroup = true
  # +       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
  # +          privileged_without_host_devices = false
  # +          runtime_engine = ""
  # +          runtime_root = ""
  # +          runtime_type = "io.containerd.runc.v1"
  # +          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
  # +            BinaryName = "/usr/bin/nvidia-container-runtime"
  # +            SystemdCgroup = true
  #     [plugins."io.containerd.grpc.v1.cri".cni]
  #     bin_dir = "/opt/cni/bin"
  #     conf_dir = "/etc/cni/net.d"
  # EOF
  # After apply the configuration patch, restart containerd:

  # sudo systemctl restart containerd


  # sudo systemctl start containerd
  # sudo systemctl enable containerd

}


