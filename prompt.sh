#!/bin/bash

# Function to check if Ollama service is running
check_ollama_running() {
  curl -s http://localhost:11434/health > /dev/null
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Ollama service is not running. Please start it with: ollama serve"
    exit 1
  fi
}

# Function to check if the specified model is available in Ollama
check_model_exists() {
  local model="$1"
  local models_json=$(curl -s http://localhost:11434/v1/models)

  # Check if the API response is empty or invalid
  if [ -z "$models_json" ] || ! echo "$models_json" | jq -e . > /dev/null 2>&1; then
    echo "❌ ERROR: Could not retrieve available models from Ollama."
    exit 1
  fi

  # Extract model names from the correct key: `.data[].id`
  local available_models=$(echo "$models_json" | jq -r '.data[].id' 2>/dev/null || echo "")

  if [ -z "$available_models" ]; then
    echo "❌ ERROR: No models are available in Ollama."
    echo "ℹ️  Try pulling a model first: ollama pull llama3:8b"
    exit 1
  fi

  if ! echo "$available_models" | grep -q "^$model$"; then
    echo "❌ ERROR: Model '$model' is not available in Ollama."
    echo "ℹ️  Available models:"
    echo "$available_models"
    exit 1
  fi
}

# Check if Ollama is running
check_ollama_running

# Get model name from argument (default: "llama3:8b")
MODEL_NAME=${1:-"llama3:8b"}

# Check if the model exists
check_model_exists "$MODEL_NAME"

# Read and clean system prompt (remove newlines and escape quotes)
SYSTEM_PROMPT=$(cat system.txt | tr '\n' ' ' | sed 's/"/\\"/g')

# Read functions from JSON and format them as a string
FUNCTIONS=$(jq -c '.functions' functions.json)

echo "🤖 Ollama Chat (Model: $MODEL_NAME) - Type 'exit' to quit."

while true; do
  # Ask for user input
  echo -n "You: "
  read USER_MESSAGE

  # Exit if the user types "exit"
  if [ "$USER_MESSAGE" == "exit" ]; then
    echo "👋 Goodbye!"
    exit 0
  fi

  # If no input is given, prompt again
  if [ -z "$USER_MESSAGE" ]; then
    echo "⚠️  Please enter a message."
    continue
  fi

  # Make API request to Ollama
  RESPONSE=$(curl -s http://localhost:11434/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"$MODEL_NAME\",
      \"messages\": [
        { \"role\": \"system\", \"content\": \"$SYSTEM_PROMPT\" },
        { \"role\": \"system\", \"content\": \"Available functions: $FUNCTIONS\" },
        { \"role\": \"user\", \"content\": \"$USER_MESSAGE\" }
      ]
    }")

  # Print formatted response
  echo "🤖 Ollama:"
  echo "$RESPONSE" | jq
  echo "----------------------------------------"
done
