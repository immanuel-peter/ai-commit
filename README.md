# 🧠 `ai-commit`

A zero-dependency Bash script that uses OpenAI's `gpt-4.1-nano` model to generate clear, contextual commit messages from your staged changes.

---

## ✨ Features

* 📝 Auto-generates concise, descriptive commit messages using AI
* 🧩 Seamlessly integrates into your Git workflow via an alias
* 💡 Fully standalone – just `bash`, `curl`, and OpenAI API access (no Node/Python/etc.)

---

## ⚙️ Installation

1. **Download the Script**

   Save [`ai-commit.sh`](./ai-commit.sh) to your preferred directory:

   ```bash
   curl -o ~/ai-commit.sh https://raw.githubusercontent.com/your/repo/main/ai-commit.sh
   ```

2. **Make It Executable**

   ```bash
   chmod +x ~/ai-commit.sh
   ```

3. **Create a Git Alias**

   Add the following Git alias (replace the path as needed):

   ```bash
   git config --global alias.ai-commit '!~/ai-commit.sh'
   ```

   > `!` lets Git run shell commands as aliases.

4. **(Optional) Add to Your PATH**

   If you want to run `ai-commit` like a command:

   ```bash
   mv ~/ai-commit.sh /usr/local/bin/ai-commit
   ```

---

## 🚀 Usage

1. Stage your changes:

   ```bash
   git add .
   ```

2. Run the AI commit:

   ```bash
   git ai-commit
   ```

   You'll be shown the generated commit message before it commits & pushes.

---

## 🔐 OpenAI API Key

Make sure your OpenAI key is exported:

```bash
export OPENAI_API_KEY="your_openai_api_key_here"
```

Add it to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) to persist:

```bash
echo 'export OPENAI_API_KEY="sk-..."' >> ~/.zshrc
```

---

## 🧪 Example

```bash
git add .
git ai-commit
```

*Output:*

```
Suggested commit message:

Fix null pointer in auth middleware
- Added check for undefined user session
- Updated error response to 401
```

---

## 📝 Notes

* Requires: `bash`, `curl`, `jq`, and a valid OpenAI API key
* Model: Uses GPT-4.1-nano via OpenAI’s `/v1/responses` endpoint
* Always review the commit message before pushing
* You can edit the AI-generated message before finalizing

---

## 📄 License

MIT — free for personal & commercial use.
