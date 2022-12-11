#!/usr/bin/env bash

kubectl apply -f namespace.yml
kubectl apply -f helmchartconfig.yml
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik --namespace=traefik

PWHASH=$(htpasswd -n ${USER} | openssl base64)
sed 's/\(  users: \).*/\1'${PWHASH}'/' secret.yml.in > secret.yml

# TRAEFIK_IP=$(kubectl get svc traefik-web-service -o custom-columns=EXTERNAL_IP:.status.loadBalancer.ingress[0].ip)
# echo "${TRAEFIK_IP} traefik.themachine.pc traefik > /etc/hosts"