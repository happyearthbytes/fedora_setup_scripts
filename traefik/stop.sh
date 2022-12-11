#!/usr/bin/env bash
kubectl delete -f 00-role.yml
kubectl delete -f 00-account.yml
kubectl delete -f 01-role-binding.yml
kubectl delete -f 02-traefik.yml
kubectl delete -f 02-traefik-services.yml
