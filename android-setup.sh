#!/bin/bash

# Updated Android Development Setup Script for Local Environments (Linux & macOS)
# Based on old GitPod Dockerfile, updated for latest tools and local installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect OS and Architecture
OS_TYPE="linux"
ARCH=$(uname -m)
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="mac"
    echo -e "${GREEN}Detected macOS ($ARCH)${NC}"
else
    echo -e "${GREEN}Detected Linux ($ARCH)${NC}"
fi

echo -e "${GREEN}Starting Android Development Environment Setup${NC}"

# Update package list based on OS
if [[ "$OS_TYPE" == "mac" ]]; then
    if command -v brew >/dev/null 2>&1; then
        echo -e "${YELLOW}Updating Homebrew...${NC}"
        # brew update # Optional: often takes a long time
    else
        echo -e "${YELLOW}Homebrew not found. Continuing without package update...${NC}"
    fi
else
    echo -e "${YELLOW}Updating package list...${NC}"
    sudo apt-get update
fi

# Set ANDROID_HOME
export ANDROID_HOME=$HOME/Android/Sdk
SHELL_CONFIG="$HOME/.zshrc"
# Check if current shell is bash
if [[ "$SHELL" == *"bash"* ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
    [[ "$OS_TYPE" == "mac" ]] && SHELL_CONFIG="$HOME/.bash_profile"
fi

echo "export ANDROID_HOME=$ANDROID_HOME" >> "$SHELL_CONFIG"
echo 'export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH' >> "$SHELL_CONFIG"

# Create Android SDK directory
mkdir -p "$ANDROID_HOME/cmdline-tools"
rm -rf "$ANDROID_HOME/cmdline-tools/latest"

# Download and install latest Android Command Line Tools
# For latest command line tools, visit: https://developer.android.com/studio#command-line-tools-only
# Version 14742923 is latest as of early 2025
CMD_LINE_TOOLS_VER="14742923"
URL="https://dl.google.com/android/repository/commandlinetools-${OS_TYPE}-${CMD_LINE_TOOLS_VER}_latest.zip"

echo -e "${YELLOW}Downloading Android Command Line Tools for ${OS_TYPE}...${NC}"
if command -v curl >/dev/null 2>&1; then
    curl -L "$URL" -o commandlinetools.zip
else
    wget -q "$URL" -o commandlinetools.zip
fi

echo -e "${YELLOW}Extracting Android Command Line Tools...${NC}"
unzip -q -o commandlinetools.zip -d "$ANDROID_HOME/cmdline-tools/"
mkdir -p "$ANDROID_HOME/cmdline-tools/latest"
mv "$ANDROID_HOME/cmdline-tools/cmdline-tools/bin" "$ANDROID_HOME/cmdline-tools/latest/"
mv "$ANDROID_HOME/cmdline-tools/cmdline-tools/lib" "$ANDROID_HOME/cmdline-tools/latest/"
rm -rf "$ANDROID_HOME/cmdline-tools/cmdline-tools"
rm -f commandlinetools.zip

# Accept licenses and install Android SDK components
# Choose emulator image based on architecture
EMULATOR_IMG="system-images;android-35;google_apis;x86_64"
if [[ "$OS_TYPE" == "mac" && "$ARCH" == "arm64" ]]; then
    EMULATOR_IMG="system-images;android-35;google_apis;arm64-v8a"
fi

echo -e "${YELLOW}Installing Android SDK components...${NC}"
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-35" "build-tools;35.0.0" "ndk;29.0.14206865" "emulator" "$EMULATOR_IMG"

# Install additional dependencies (Linux only)
if [[ "$OS_TYPE" == "linux" ]]; then
    # if error occur try install these
    # sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
    :
fi

echo -e "${GREEN}Android Development Environment Setup Complete!${NC}"
echo -e "${YELLOW}Please restart your terminal or run 'source $SHELL_CONFIG' to apply environment changes.${NC}"
echo -e "${YELLOW}You can now compile Expo Android apps using the installed tools.${NC}"
