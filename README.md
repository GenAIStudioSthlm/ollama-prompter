# Ollama Chat Script

A Bash script that interacts with Ollama's chat API, allowing users to communicate with locally hosted models.

## Features

Interactive chat – Type messages and receive responses in real-time.
Supports multiple models – Choose a model at startup.
Checks Ollama status – Ensures the service is running.
Validates models – Verifies if the requested model is available.
Function calling support – Loads functions dynamically from functions.json.
Formatted output – Uses jq for better readability.
Installation

## Install Ollama
Make sure Ollama is installed and running:
```ollama serve```

## Install jq (if not already installed)
### macOS
```brew install jq```
### Debian/Ubuntu
```sudo apt install jq```

### Clone this repository (if applicable)

```git clone <repo-url>```

```cd <repo-folder>```

### Make the script executable
```chmod +x prompt.sh```

## Usage

Start Chat with a Specific Model

```./prompt.sh llama3:8b```

If no model is specified, it defaults to llama3:8b.

Example Session
```
🤖 Ollama Chat (Model: llama3:8b) - Type 'exit' to quit.
You: What is the weather in Stockholm?
🤖 Ollama:
{
"choices": [
{
"message": {
"role": "assistant",
"content": "{ "function": "get_weather", "arguments": { "location": "Stockholm" } }"
}
}
]
}
You: exit
👋 Goodbye!
```

## Configuration

### System Prompt
Modify system.txt to set the AI's behavior.

### Function Calling
Define functions in functions.json:
```
{
"functions": [
{
"name": "get_weather",
"description": "Get the weather for a given location.",
"parameters": {
"location": { "type": "string", "description": "City name" }
}
}
]
}
```

## Troubleshooting

Ollama is not running
❌ ERROR: Ollama service is not running. Please start it with: ollama serve
Run:
ollama serve

Model not found
❌ ERROR: Model 'mistral' is not available in Ollama.
ℹ️ Available models:
llama3:8b
llama3:70b
starcoder2:3b

Run:
ollama pull mistral

## License

MIT – Feel free to modify and use this script as needed.