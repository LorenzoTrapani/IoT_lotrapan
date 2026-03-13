#!/bin/bash

set -e

GREEN='\033[0;32m'
ORANGE='\033[38;5;208m'
RESET='\033[0m'

REPO_URL="https://github.com/LorenzoTrapani/IoT_lotrapan.git"
APP_NAME="wil-playground"

argocd repo add "$REPO_URL"

if argocd app get "$APP_NAME" &>/dev/null; then
    echo -e "${GREEN}Application '$APP_NAME' already exists${RESET}"
else
    echo -e "${ORANGE}Creating ArgoCD application...${RESET}"
    argocd app create "$APP_NAME" \
        --repo "$REPO_URL" \
        --path p3/app \
        --dest-server https://kubernetes.default.svc \
        --dest-namespace dev \
        --sync-policy automated \
        --auto-prune \
        --self-heal
fi

echo -e "${ORANGE}Syncing application...${RESET}"
argocd app sync "$APP_NAME"

echo -e "${ORANGE}Waiting for application to be healthy...${RESET}"
argocd app wait "$APP_NAME" --health

echo -e "${GREEN}=== Application deployed ===${RESET}"
argocd app get "$APP_NAME"
