#!/bin/bash

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
ORANGE='\033[38;5;208m'
RESET='\033[0m'

ARGOCD_NAMESPACE="argocd"
ARGOCD_VERSION="stable"

install_argocd() {
    echo -e "${ORANGE}Installing ArgoCD in namespace '$ARGOCD_NAMESPACE'...${RESET}"

    kubectl apply -n "$ARGOCD_NAMESPACE" \
        --server-side \
        -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

    echo -e "${ORANGE}Waiting for ArgoCD pods to be ready...${RESET}"
    kubectl wait --for=condition=Ready pod --all \
        -n "$ARGOCD_NAMESPACE" --timeout=180s

    echo -e "${GREEN}ArgoCD installed${RESET}"
}

expose_argocd() {
    echo -e "${ORANGE}Exposing ArgoCD server...${RESET}"

    kubectl patch svc argocd-server -n "$ARGOCD_NAMESPACE" \
        -p '{"spec": {"type": "NodePort"}}'

    echo -e "${GREEN}ArgoCD server exposed as NodePort${RESET}"
}

get_admin_password() {
    echo -e "${ORANGE}Retrieving ArgoCD admin password...${RESET}"

    PASSWORD=$(kubectl get secret argocd-initial-admin-secret \
        -n "$ARGOCD_NAMESPACE" \
        -o jsonpath="{.data.password}" | base64 -d)

    echo -e "${GREEN}ArgoCD admin credentials:${RESET}"
    echo -e "  user:     admin"
    echo -e "  password: ${PASSWORD}"
}

deploy_app() {
    echo -e "${ORANGE}Deploying application via ArgoCD...${RESET}"

    kubectl apply -f ../confs/app.yaml

    echo -e "${GREEN}Application deployed${RESET}"
}

# --- Main ---
echo -e "${BLUE}=== Setup ArgoCD ===${RESET}"
install_argocd
expose_argocd
get_admin_password
# deploy_app
echo -e "${BLUE}=== ArgoCD ready ===${RESET}"
echo -e "${GREEN}Access the UI: https://localhost:8080  (user: admin)${RESET}"
