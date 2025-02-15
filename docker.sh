#!/bin/bash

FILE_PATH="./.env"

# Function to check if Docker daemon is running
check_docker() {
    docker info >/dev/null 2>&1
}

# Function to start Docker Desktop on macOS
start_docker() {
    echo "Attempting to start Docker..."
    # Using AppleScript to start Docker Desktop
    open -a Docker
    # Wait for Docker to start (adjust time as needed)
    echo "Waiting for Docker to launch..."
    while ! docker info >/dev/null 2>&1; do
        sleep 5
        echo "Waiting for Docker to start..."
    done
    echo "Docker is running."
}

# Function to start the PostgreSQL container
start_postgresql_container() {
    CONTAINER_NAME=$(grep "CONTAINER_NAME" $FILE_PATH | cut -d'=' -f2)  # Replace with your container's name
    echo "$CONTAINER_NAME"
    echo "Starting PostgreSQL container: $CONTAINER_NAME"
    docker start "$CONTAINER_NAME"
}

# Check if Docker is running
if check_docker; then
    echo "Docker is already running."
else
    echo "Docker is not running."
    start_docker
fi

# Start PostgreSQL container
start_postgresql_container
