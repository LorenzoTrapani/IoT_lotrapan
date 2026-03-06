#!/bin/bash

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
ORANGE='\033[38;5;208m'
RESET='\033[0m'

CLUSTER_NAME="lotrapanCluster"

create_cluster() {
    if k3d cluster list | grep -q "^${CLUSTER_NAME}"; then
        echo -e "${GREEN}Cluster '$CLUSTER_NAME' already exists${RESET}"
        return
    fi

    echo -e "${ORANGE}Creating K3d cluster: $CLUSTER_NAME...${RESET}"
    k3d cluster create "$CLUSTER_NAME" \
        --port "8888:8888@loadbalancer" \
        --servers 1 \
        --agents 2
    echo -e "${GREEN}Cluster '$CLUSTER_NAME' created${RESET}"

    mkdir -p "$HOME/.kube"
    k3d kubeconfig merge "$CLUSTER_NAME" --kubeconfig-switch-context -o "$HOME/.kube/config"
    echo -e "${GREEN}kubeconfig saved to $HOME/.kube/config${RESET}"
}

create_namespaces() {
    echo -e "${ORANGE}Creating namespaces...${RESET}"

    for NS in argocd dev; do
        if kubectl get namespace "$NS" &>/dev/null; then
            echo -e "${GREEN}Namespace '$NS' already exists${RESET}"
        else
            kubectl create namespace "$NS"
            echo -e "${GREEN}Namespace '$NS' created${RESET}"
        fi
    done
}

# --- Main ---
echo -e "${BLUE}=== Setup cluster K3d ===${RESET}"
create_cluster
create_namespaces
echo -e "${BLUE}=== Cluster ready ===${RESET}"
