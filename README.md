# AI Commit

A bash script that uses OpenAI's GPT-4.1-nano model to automatically generate meaningful commit messages based on your staged changes.

## Features

- Automatically generates concise and clear commit messages
- Supports editing the generated message before committing
- Handles both subject line (max 60 chars) and detailed body
- Pushes changes to remote repository
- Built-in error handling and validation

## Prerequisites

- Git repository
- OpenAI API key
- `jq` (for JSON parsing)
- `curl` (for API requests)
- A text editor (defaults to `nano` if `$EDITOR` is not set)

## Installation

1. Download the script:

```bash
curl -O https://raw.githubusercontent.com/immanuel-peter/ai-commit/main/ai-commit.sh
```

2. Make it executable:

```bash
chmod +x ai-commit.sh
```

3. Set your OpenAI API key:

```bash
export OPENAI_API_KEY='your-api-key-here'
```

## Usage

1. Stage your changes:

```bash
git add .
```

2. Run the script:

```bash
./ai-commit.sh
```

The script will:

1. Check if you're in a git repository
2. Verify you have staged changes
3. Generate a commit message using GPT-4.1-nano
4. Show you the generated message
5. Allow you to edit the message if desired
6. Commit and push your changes

## Error Handling

The script includes checks for:

- Git repository presence
- Staged changes
- OpenAI API key
- `jq` installation
- Commit and push operations

## Contributing

Feel free to open issues or submit pull requests for any improvements.

## License

MIT License - feel free to use this script in your projects.

## Disclaimer

This script uses the OpenAI API, which may incur costs depending on your usage. Please review OpenAI's pricing and terms of service.
