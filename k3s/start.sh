#!/usr/bin/env bash
cp config.yaml /etc/rancher/k3s/config.yaml
sudo k3s server

#    --write-kubeconfig value, -o value         (client) Write kubeconfig for admin client to this file [$K3S_KUBECONFIG_OUTPUT]
#    --kube-apiserver-arg value                 (flags) Customized flag for kube-apiserver process
#    --node-name value                          (agent/node) Node name [$K3S_NODE_NAME]
#    --container-runtime-endpoint value         (agent/runtime) Disable embedded containerd and use the CRI socket at the given path; when used with --docker this sets the docker socket path
#    --private-registry value                   (agent/runtime) Private registry configuration file (default: "/etc/rancher/k3s/registries.yaml")
