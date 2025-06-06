#!/bin/bash

# <-- ai-commit.sh -->

# Ensure we are in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not a git repository"
    exit 1
fi

# Check for staged changes
if ! git diff --cached --quiet; then
    DIFF=$(git diff --cached)
else
    echo "No staged changes"
    exit 1
fi

# Grab OpenAI API key
if [ -z "$OPENAI_API_KEY" ]; then
    echo "OPENAI_API_KEY is not set"
    exit 1
fi

# Create prompt for gpt-4.1-nano
read -r -d '' PROMPT <<EOF
Generate a concise and clear git commit message (max 60 chars subject, plus optional detailed body) describing the staged changes. The detailed body must use bullets. Do not add fluff like "**Commit Message**" or "**Optional detailed body**". Just describe the changes.
$DIFF
EOF

# Payload for OpenAI API
json_payload=$(jq -n \
    --arg prompt "$PROMPT" \
    '{
        "model": "gpt-4.1-nano",
        "input": $prompt
    }'
)

# Query OpenAI API
RESPONSE=$(curl -s "https://api.openai.com/v1/responses" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$json_payload"
)

# Extract commit message from response
if command -v jq > /dev/null; then
    COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.output[0].content[0].text')
else
    echo "Could not parse response"
    exit 1
fi

# Show user the message and ask if they're ok with it
echo -e "\nSuggested commit message:\n"
echo "$COMMIT_MSG"
echo -e "\nAre you ok with this commit message? (y/n): "
read -r OK_CHOICE
if [[ "$OK_CHOICE" =~ ^[Nn]$ ]]; then
    TMP_FILE=$(mktemp)
    echo "$COMMIT_MSG" > "$TMP_FILE"
    ${EDITOR:-nano} "$TMP_FILE"
    COMMIT_MSG=$(cat "$TMP_FILE")
    rm "$TMP_FILE"
fi

# Commit with the edited message
git commit -m "$COMMIT_MSG"
if [ $? -ne 0 ]; then
    echo "git commit failed."
    exit 1
fi

# Push to remote
git push origin main
if [ $? -ne 0 ]; then
    echo "git push failed."
    exit 1
fi

# Done!
echo "Committed and pushed with LLM-generated message."
