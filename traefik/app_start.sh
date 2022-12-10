#!/usr/bin/env bash
APP_DIR=example_app
kubectl apply -f ${APP_DIR}/03-whoami-services.yml
kubectl apply -f ${APP_DIR}/03-whoami.yml
kubectl apply -f ${APP_DIR}/04-whoami-ingress.yml
