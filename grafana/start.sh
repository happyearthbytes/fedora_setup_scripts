#!/usr/bin/env bash
kubectl create -f monitoring-namespace.yaml
kubectl create -f grafana-datasource-config.yaml
kubectl create -f deployment.yaml
kubectl create -f service.yaml
