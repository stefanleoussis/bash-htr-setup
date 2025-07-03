#!/bin/bash

# Save the current directory
ORIGINAL_DIR=$(pwd)

# ----- Setup Ngrok -----

# Start tmux session (-d: detach, -s: session name)
tmux new-session -d -s ngrok_session 'ngrok http 4000'

# Name of the tmux session
SESSION_NAME="ngrok_session"

# Check if the tmux session exists
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
  echo "Session $SESSION_NAME already exists. Killing it..."
  # Kill the existing tmux session
  tmux kill-session -t $SESSION_NAME
fi

# Start tmux session (-d: detach, -s: session name)
echo "Starting new tmux session with ngrok..."
tmux new-session -d -s ngrok_session 'ngrok http 4000'

# Wait for ngrok to start
sleep 10

echo "ngrok is now running in the tmux session $SESSION_NAME."

# Extract Forwarding Address / Expo URL
URL=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')


# ----- Setup Environment Variables -----

# Define the .env file path
FILE_PATH="./.env"
# Read the line containing 'ENV_FILE' and extract the path
ENV_FILE=$(grep "ENV_FILE" $FILE_PATH | cut -d'=' -f2)

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



# # ----- Start Expo -----
FRONTEND=$(grep "FRONTEND" $FILE_PATH | cut -d'=' -f2)
cd $FRONTEND
cursor .
cd $ORIGINAL_DIR

# ----- Start Backend -----
BACKEND=$(grep "BACKEND" $FILE_PATH | cut -d'=' -f2)
cd $BACKEND
echo $BACKEND
cursor .
cd $ORIGINAL_DIR

# ----- Start Docker Database -----
cd $ORIGINAL_DIR

#bash docker.sh
