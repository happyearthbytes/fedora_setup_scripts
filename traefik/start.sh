#!/usr/bin/env bash
kubectl apply -f 00-role.yml
kubectl apply -f 00-account.yml
kubectl apply -f 01-role-binding.yml
kubectl apply -f 02-traefik.yml
kubectl apply -f 02-traefik-services.yml
