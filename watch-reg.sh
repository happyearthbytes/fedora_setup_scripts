#!/usr/bin/env bash
NAMESPACE="-n kube-system"
COMMAND="kubectl get po,deploy,svc,job,helmchartconfigs,helmcharts,pvc,secrets -o wide ${NAMESPACE} | expand | cut -c-\${COLUMNS} | sed '/^$/d'"
watch -t -n1 --color -d ${COMMAND}
