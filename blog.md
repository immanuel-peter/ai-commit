# 🧠 How to Automate Your Git Commit Messages with an LLM

> Writing commit messages is essential—but also kind of annoying. Here's how to automate it using a local Bash script and OpenAI.

---

## 🪄 What This Project Does

This project introduces a **bash script** that:

1. Detects staged changes in your Git repo.
2. Sends them to a **local-friendly LLM** (`gpt-4.1-nano` in this case).
3. Suggests a clean, well-written commit message.
4. Prompts you to approve or edit it.
5. Commits and pushes automatically.

---

## 🛠️ Requirements

- Git installed
- OpenAI API key with model access (e.g., `gpt-4.1-nano`)
- [`jq`](https://stedolan.github.io/jq/) for parsing JSON
- A terminal editor like `nano`, `vim`, or `nvim`
- Bash shell environment

---

## 📁 How It Works — Line by Line

---

### 1. 🧭 Verify Git Context

```bash
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not a git repository"
    exit 1
fi
```

We start by ensuring the script is running inside a valid Git repository. If not, we exit early to avoid errors.

---

### 2. 🧪 Check for Staged Changes

```bash
if ! git diff --cached --quiet; then
    DIFF=$(git diff --cached)
else
    echo "No staged changes"
    exit 1
fi
```

This section checks if there are **staged changes** using `git diff --cached`. If none exist, we exit. If there are, we capture the diff into a variable.

---

### 3. 🔑 Check for OpenAI API Key

```bash
if [ -z "$OPENAI_API_KEY" ]; then
    echo "OPENAI_API_KEY is not set"
    exit 1
fi
```

The script expects the API key to be stored in your environment (`.bashrc` or `.zshrc`). If it's not found, we don’t proceed.

---

### 4. 🧠 Craft Prompt for the LLM

```bash
read -r -d '' PROMPT <<EOF
Generate a concise and clear git commit message (max 60 chars subject, plus optional detailed body) describing the staged changes. Do not add fluff like "**Commit Message**" or "**Optional detailed body**". Just describe the changes.
$DIFF
EOF
```

We generate a clear and structured prompt that tells the LLM:

- To write a short, descriptive commit message.
- Not to include formatting or excess labeling.
- To base the response purely on the Git diff.

---

### 5. 📦 Format the API Payload

```bash
json_payload=$(jq -n \
    --arg prompt "$PROMPT" \
    '{
        "model": "gpt-4.1-nano",
        "input": $prompt
    }'
)
```

We use `jq` to structure the JSON request body for the OpenAI API.

---

### 6. 🌐 Call the OpenAI API

```bash
RESPONSE=$(curl -s "https://api.openai.com/v1/responses" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$json_payload"
)
```

This makes a `POST` request to the OpenAI API and stores the response for parsing.

---

### 7. 🧼 Extract the Commit Message

```bash
if command -v jq > /dev/null; then
    COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.output[0].content[0].text')
else
    echo "Could not parse response"
    exit 1
fi
```

Here we extract the actual message content from the JSON response. If `jq` isn’t installed, the script exits.

---

### 8. ✅ Confirm with the User

```bash
echo -e "\nSuggested commit message:\n"
echo "$COMMIT_MSG"
echo -e "\nAre you ok with this commit message? (y/n): "
read -r OK_CHOICE
```

You’re shown the suggested message and prompted to accept or revise it.

---

### 9. 📝 Manual Edits (If Needed)

```bash
if [[ "$OK_CHOICE" =~ ^[Nn]$ ]]; then
    TMP_FILE=$(mktemp)
    echo "$COMMIT_MSG" > "$TMP_FILE"
    ${EDITOR:-nano} "$TMP_FILE"
    COMMIT_MSG=$(cat "$TMP_FILE")
    rm "$TMP_FILE"
fi
```

If you answer "no", the script opens a temp file in your terminal editor to let you revise the message.

---

### 10. 💾 Commit + 🚀 Push

```bash
git commit -m "$COMMIT_MSG"
if [ $? -ne 0 ]; then
    echo "git commit failed."
    exit 1
fi

git push
if [ $? -ne 0 ]; then
    echo "git push failed."
    exit 1
fi

echo "Committed and pushed with LLM-generated message."
```

We commit using your approved message and push to your current Git remote.

---

## 🧱 Full Script

Here’s the complete `ai-commit.sh` file:

```bash
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
Generate a concise and clear git commit message (max 60 chars subject, plus optional detailed body) describing the staged changes. Do not add fluff like "**Commit Message**" or "**Optional detailed body**". Just describe the changes.
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
git push
if [ $? -ne 0 ]; then
    echo "git push failed."
    exit 1
fi

# Done!
echo "Committed and pushed with LLM-generated message."
```

---

## ⚡ Bonus Tips

- Add a Git alias with:

  ```bash
  git config --global alias.ai-commit '!/usr/local/bin/ai-commit.sh'
  ```

- Set your API key in `.bashrc` or `.zshrc`:

  ```bash
  export OPENAI_API_KEY="your-secret-key"
  ```

---

## 🧠 Final Thoughts

This is a powerful automation technique that gives you:

- Consistency across your commit history
- Cognitive offloading for better dev flow
- A fun way to integrate LLMs locally
