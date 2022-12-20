#!/usr/bin/env bash
helm repo add nvidia-device-plugin https://nvidia.github.io/k8s-device-plugin
helm template \
    nvidia-device-plugin \
    --namespace nvidia-device-plugin \
    --set runtimeClassName=nvidia \
    nvidia-device-plugin/nvidia-device-plugin > nvidia-device-plugin.yml