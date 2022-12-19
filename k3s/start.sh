#!/usr/bin/env bash

sleep 1
sudo cp config.toml.tmpl /var/lib/rancher/k3s/agent/etc/containerd/
sudo cp config.toml.tmpl /etc/containerd/


sudo systemctl start k3s
sudo systemctl enable k3s
sleep 1
kubectl config view --raw > ~/.kube/config
chmod 600 ~/.kube/config

# sleep 5
# kubectl -n kube-system create serviceaccount tiller
# kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
# helm init --service-account tiller

#    --write-kubeconfig value, -o value         (client) Write kubeconfig for admin client to this file [$K3S_KUBECONFIG_OUTPUT]
#    --kube-apiserver-arg value                 (flags) Customized flag for kube-apiserver process
#    --node-name value                          (agent/node) Node name [$K3S_NODE_NAME]
#    --container-runtime-endpoint value         (agent/runtime) Disable embedded containerd and use the CRI socket at the given path; when used with --docker this sets the docker socket path
#    --private-registry value                   (agent/runtime) Private registry configuration file (default: "/etc/rancher/k3s/registries.yaml")
