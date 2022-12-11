#!/usr/bin/env bash
COMMAND="kubectl get pods,deployments,services,ingress,daemonset -o wide -A | expand | cut -c-\${COLUMNS} | sed '/^$/d'"
watch -t -n1 --color -d ${COMMAND}
