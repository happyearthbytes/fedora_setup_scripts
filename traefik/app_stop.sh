#!/usr/bin/env bash
APP_DIR=example_app
kubectl delete -f ${APP_DIR}/04-whoami-ingress.yml
kubectl delete -f ${APP_DIR}/03-whoami.yml
kubectl delete -f ${APP_DIR}/03-whoami-services.yml
