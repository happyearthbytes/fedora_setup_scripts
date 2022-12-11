#!/usr/bin/env bash
NAMESPACE=""
# NAMESPACE="-A"
# NAMESPACE="-n proxy"
COMMAND="kubectl get pods,deployments,services,ingress,daemonset -o wide ${NAMESPACE} | expand | cut -c-\${COLUMNS} | sed '/^$/d'"
watch -t -n1 --color -d ${COMMAND}
