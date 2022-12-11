#!/usr/bin/env bash
kubectl apply -f 00-role.yml
sleep 1
kubectl apply -f 00-account.yml
sleep 1
kubectl apply -f 01-role-binding.yml
sleep 1
kubectl apply -f 02-traefik.yml
sleep 1
kubectl apply -f 02-traefik-services.yml
sleep 5
TRAEFIK_IP=$(kubectl get svc traefik-web-service -o custom-columns=EXTERNAL_IP:.status.loadBalancer.ingress[0].ip)
echo "${TRAEFIK_IP} traefik.themachine.pc traefik > /etc/hosts"