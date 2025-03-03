#!/bin/bash
set -e

# Ensure required environment variables are set
: "${AZP_URL:?Environment variable AZP_URL is required}"
: "${AZP_TOKEN:?Environment variable AZP_TOKEN is required}"
: "${AZP_POOL:?Environment variable AZP_POOL is required}"

# Set working directory
cd /azp/agent

# Set a default agent name if not provided
AZP_AGENT_NAME="${AZP_AGENT_NAME:-$(hostname)}"

# Configure and start the Azure DevOps agent
./config.sh --unattended --url "$AZP_URL" --auth PAT --token "$AZP_TOKEN" --pool "$AZP_POOL" --agent "$AZP_AGENT_NAME" --replace

# Run the agent
./run.sh
