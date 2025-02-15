#!/bin/bash

# ----- Setup Ngrok -----

# Start tmux session (-d: detach, -s: session name)
# tmux new-session -d -s ngrok_session 'ngrok http 8080'

# # Wait for ngrok to start
# sleep 10

# Extract Forwarding Address / Expo URL
# URL=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')
URL="TEST"


# ----- Setup Environment Variables -----

# Define the .env file path
ENV_FILE="./.env"

# Create a temporary file
TMP_FILE=$(mktemp)
chmod 644 $TMP_FILE

# Flag to check if the variable was updated
UPDATED=0

# Read the .env and update the variables (IFS: Internal Field Separator, -r: do not interpret backslashes as escape characters
# <"$ENV_FILE": The while loop reads from the .env file)
while IFS='=' read -r key value
do
    if [ "$key" == "EXPO_PUBLIC_BACKEND_URL" ]; then
        echo "EXPO_PUBLIC_BACKEND_URL=$URL" >> $TMP_FILE
        UPDATED=1
    # Empty line
    elif [ "$key" == "" ] && [ "$value" == "" ]; then
     echo "$key$value" >> "$TMP_FILE"
    # Commented line
    elif [ "$key" == "#" ]; then
        echo "$key=$value">>$TMP_FILE
    else
        echo "$key=$value">>$TMP_FILE
    fi
done < "$ENV_FILE"

# If the variable was not found and updated, append it
if [ $UPDATED -eq 0 ]; then
    echo "EXPO_PUBLIC_BACKEND_URL=$URL">>$TMP_FILE
fi

# Replace the original .env file with the updated temp file
mv $TMP_FILE $ENV_FILE


echo "Updated EXPO_PUBLIC_BACKEND_URL to $URL in $ENV_FILE"