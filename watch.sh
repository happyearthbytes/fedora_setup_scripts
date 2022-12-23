#!/usr/bin/env bash
# NAMESPACE=""
NAMESPACE="-A"
# NAMESPACE="-n proxy"
COMMAND="kubectl get pods,deployments,services,ingress,daemonset,helmchartconfig,helmchart -o wide ${NAMESPACE} | expand | cut -c-\${COLUMNS} | sed '/^$/d'"
watch -t -n1 --color -d ${COMMAND}

COMMAND="kubectl get pods,deployments,services,ingress,daemonset ${NAMESPACE} -o go-template-file=watch.go.tpl  | expand | cut -c-\${COLUMNS} | sed '/^$/d'"
watch -t -n1 --color -d ${COMMAND}


# kubectl get pods,deployments,services,ingress,daemonset -A -o jsonpath='{.metadata.name}'
# ,NAME:.metadata.name,CTR:.spec.containers[*].name,STATUS:.status.containerStatuses[*].state.reason,PHASE:.status.phase,IP:.status.podIP,IP:.spec.clusterIP,NODE:.spec.nodeName,PORTS:.spec.ports[*].port,PORTS:.spec.ports[*].name,AAA:'".status.containerStatuses"''^C