#!/bin/bash

set -e

BLUE='\033[0;34m'
RESET='\033[0m'


echo -e "${BLUE}=== Step 1: Install ===${RESET}"
bash "scripts/install.sh"

echo -e "${BLUE}=== Step 2: Setup ===${RESET}"
bash "scripts/setup.sh"

echo -e "${BLUE}=== Step 3: Deploy ===${RESET}"
bash "scripts/deploy.sh"
