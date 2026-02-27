#!/usr/bin/env bash

DEBUG="${DEBUG:-0}"
# OpenRouter API Configuration
OPENROUTER_API_URL="https://openrouter.ai/api/v1/chat/completions"
OPENROUTER_API_KEY="${OPENROUTER_API_KEY:?Environment variable OPENROUTER_API_KEY is required}"

# Default values
MODEL=""
PROMPT_FILES=()
ADDITIONAL_TEXTS=()

# Supported image extensions
IMAGE_EXTENSIONS=("jpg" "jpeg" "png" "gif" "webp" "bmp" "tiff" "tif")

# Display usage information
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Send prompts to LLMs via OpenRouter API

Required:
  -m, --model MODEL        Specify the model to use (e.g., "openai/gpt-4o")
  -f, --file PATH          Path to file containing the prompt (text or image, can be used multiple times)

Optional:
  -a, --additional TEXT    Additional text to append to the prompt (can be used multiple times)
  -h, --help               Show this help message

Supported image formats: jpg, jpeg, png, gif, webp, bmp, tiff, tif

Examples:
  $0 -m "openai/gpt-3.5-turbo" -f prompt.txt
  $0 -m "anthropic/claude-3-haiku" -f prompt.txt -a "Describe this image."
  $0 -m "meta-llama/llama-3.1-8b-instruct" -f "input1.txt" -f "input2.txt" -a "Context:" -a "More details"
  $0 --model="openai/gpt-4o" --file="image.png" --additional="What's in this image?"
  $0 --model="openai/gpt-4o" --file="image1.jpg" --file="image2.png" --file="prompt.txt" -a "Compare these images"

Note: Set OPENROUTER_API_KEY environment variable with your API key.
All files and additional texts are concatenated in the order provided.
When using image files, they will be encoded as base64 and sent to vision-enabled models.
EOF
    exit 1
}

# Check if a file is an image based on extension
is_image_file() {
    local file="$1"
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    for img_ext in "${IMAGE_EXTENSIONS[@]}"; do
        if [[ "$ext" == "$img_ext" ]]; then
            return 0
        fi
    done
    return 1
}

# Get MIME type of a file
get_mime_type() {
    local file="$1"
    
    # Try using file command if available
    if command -v file &>/dev/null; then
        local mime
        mime=$(file -b --mime-type "$file" 2>/dev/null)
        if [[ -n "$mime" ]]; then
            echo "$mime"
            return 0
        fi
    fi
    
    # Fallback to extension-based detection
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    case "$ext" in
        jpg|jpeg) echo "image/jpeg" ;;
        png)      echo "image/png" ;;
        gif)      echo "image/gif" ;;
        webp)     echo "image/webp" ;;
        bmp)      echo "image/bmp" ;;
        tiff|tif) echo "image/tiff" ;;
        *)        echo "application/octet-stream" ;;
    esac
}

# Convert image to base64 data URL
image_to_data_url() {
    local file="$1"
    local mime_type
    mime_type=$(get_mime_type "$file")
    local base64_data
    
    base64_data=$(base64 -w 0 "$file" 2>/dev/null) || base64_data=$(base64 "$file" | tr -d '\n')
    
    echo "data:${mime_type};base64,${base64_data}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -f|--file)
            PROMPT_FILES+=("$2")
            shift 2
            ;;
        -a|--additional)
            ADDITIONAL_TEXTS+=("$2")
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            ;;
    esac
done

# Validate required arguments
if [[ -z "$MODEL" ]]; then
    echo "Error: Model is required. Use -m or --model"
    usage
fi

# Check if all files exist and are readable
for file in "${PROMPT_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' does not exist"
        exit 1
    fi
    if [[ ! -r "$file" ]]; then
        echo "Error: File '$file' is not readable"
        exit 1
    fi
done

# Check if base64 is available
if ! command -v base64 &>/dev/null; then
    echo "Error: base64 command is required for image encoding"
    exit 1
fi

# Separate text and image files, build content array
CONTENT_ARRAY=()
TEXT_CONTENT=""
HAS_IMAGES=0

for file in "${PROMPT_FILES[@]}"; do
    if is_image_file "$file"; then
        HAS_IMAGES=1
        if [[ "$DEBUG" -ne 0 ]]; then
            echo "Detected image file: $file"
        fi
        
        data_url=$(image_to_data_url "$file")
        
        # Add image to content array
        CONTENT_ARRAY+=("{\"type\": \"image_url\", \"image_url\": {\"url\": \"${data_url}\"}}")
    else
        # Read text file
        content=$(<"$file")
        if [[ -n "$content" ]]; then
            TEXT_CONTENT+="$content"$'\n'
        fi
    fi
done

# Append all additional texts
if [[ ${#ADDITIONAL_TEXTS[@]} -gt 0 ]]; then
    # Filter out empty additional texts
    for text in "${ADDITIONAL_TEXTS[@]}"; do
        if [[ -n "$text" ]]; then
            TEXT_CONTENT+="$text"$'\n'
        fi
    done
fi

# Remove trailing newlines from text content
TEXT_CONTENT=${TEXT_CONTENT%$'\n'}
TEXT_CONTENT=${TEXT_CONTENT:0:$(( ${#TEXT_CONTENT} - 0 ))}  # Trim trailing whitespace

# Validate we have some content
if [[ -z "$TEXT_CONTENT" && ${#CONTENT_ARRAY[@]} -eq 0 ]]; then
    echo "Error: Final prompt is empty after processing"
    exit 1
fi

# 1. Build the content array using a temporary file to avoid ARG_MAX limits entirely
TEMP_CONTENT_FILE=$(mktemp)

# Start building the array
echo "[" > "$TEMP_CONTENT_FILE"
FIRST=1

# Add Text Content if it exists
if [[ -n "$TEXT_CONTENT" ]]; then
    # Use -Rs to safely JSON-escape the text from stdin
    echo -n "$TEXT_CONTENT" | jq -Rs '{type: "text", text: .}' >> "$TEMP_CONTENT_FILE"
    FIRST=0
fi

# Add Image Files
for file in "${PROMPT_FILES[@]}"; do
    if is_image_file "$file"; then
        if [[ $FIRST -eq 0 ]]; then echo "," >> "$TEMP_CONTENT_FILE"; fi
        
        # STREAM the file into base64 and then into jq's stdin
        # This ensures the Base64 string NEVER exists as a shell argument
        mime_type=$(get_mime_type "$file")
        base64_data=$(base64 -w 0 "$file" 2>/dev/null || base64 "$file" | tr -d '\n')
        
        # We pass the data via a pipe so jq reads it as raw input, not an argument
        echo "$base64_data" | jq -Rs --arg mime "$mime_type" \
            '{type: "image_url", image_url: {url: ("data:" + $mime + ";base64," + .)}}' >> "$TEMP_CONTENT_FILE"
            
        FIRST=0
        HAS_IMAGES=1
    fi
done
echo "]" >> "$TEMP_CONTENT_FILE"

# 2. Build and Send the final Payload via Pipes
# We use --slurpfile to read the large content array from the file
response=$(jq -n \
    --arg model "$MODEL" \
    --slurpfile content "$TEMP_CONTENT_FILE" \
    '{model: $model, messages: [{role: "user", content: $content[0]}]}' | \
    curl -s -X POST "$OPENROUTER_API_URL" \
    -H "Authorization: Bearer $OPENROUTER_API_KEY" \
    -H "Content-Type: application/json" \
    -H "HTTP-Referer: ${HTTP_REFERER:-https://localhost}" \
    -H "X-Title: ${X_TITLE:-CLI-Client}" \
    --data-binary @-)

# Clean up
rm -f "$TEMP_CONTENT_FILE"

# Check for curl errors
curl_exit=$?
if [[ $curl_exit -ne 0 ]]; then
    echo "Error: curl failed with exit code $curl_exit"
    exit $curl_exit
fi

# Extract and display the response content
if echo "$response" | jq -e '.choices[0].message.content' >/dev/null 2>&1; then
    echo "$response" | jq -r '.choices[0].message.content'
else
    echo "Error: Unexpected response format"
    echo "$response" | jq . 2>/dev/null || echo "$response"
    exit 1
fi
