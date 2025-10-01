#!/bin/bash

# Create QP Agent GitHub Repository
# This script creates a new repository for your QP Agent Apex code

echo "=== Creating QP Agent GitHub Repository ==="

# GitHub repository details
REPO_NAME="QP-Agent"
REPO_DESCRIPTION="QP Agent Apex Code - Salesforce AI Agent Implementation with Version Control"
REPO_PRIVATE="false"  # Set to "true" if you want it private

# Check if GitHub token is available
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable not set."
    echo "Please set your GitHub token:"
    echo "export GITHUB_TOKEN=your_github_token_here"
    exit 1
fi

# Create the repository using GitHub API
echo "Creating repository: $REPO_NAME"
echo "Description: $REPO_DESCRIPTION"

curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d "{
    \"name\": \"$REPO_NAME\",
    \"description\": \"$REPO_DESCRIPTION\",
    \"private\": $REPO_PRIVATE,
    \"auto_init\": true,
    \"license_template\": \"mit\"
  }"

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Repository Created Successfully! ==="
    echo "Repository: https://github.com/Alinahvi/$REPO_NAME"
    echo ""
    echo "Next steps:"
    echo "1. Clone the new repository:"
    echo "   git clone https://github.com/Alinahvi/$REPO_NAME.git"
    echo "2. Copy your QP Agent Apex files to the new repo"
    echo "3. Set up proper versioning and branching strategy"
    echo ""
    echo "Would you like me to help you set up the local repository structure?"
else
    echo "Error: Failed to create repository. Please check your token and try again."
    exit 1
fi
