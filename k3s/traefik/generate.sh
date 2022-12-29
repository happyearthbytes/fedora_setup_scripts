#!/usr/bin/env bash
# NOTE: This file is automatically generated!
# TODO: currently this needs to be run from the project directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd ${SCRIPT_DIR}/..
CHART_SELECTOR=traefik
CHART_NAME=traefik
CHART_URL=https://traefik.github.io/charts
./scripts/get_helm.sh \
  ${CHART_SELECTOR} \
  ${CHART_NAME} \
  ${CHART_URL}