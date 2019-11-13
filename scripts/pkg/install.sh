#!/bin/sh

set -e

reset="\033[0m"
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
cyan="\033[36m"
white="\033[37m"


# Detect platform
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  PLATFORM='linux'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  PLATFORM='macos'
else
  echo "$red Sorry, there's no serverless binary installer available for this platform. Please open request for it at Serverless GitHub repository.$reset"
  exit 1
fi

# Detect architecture
MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  ARCH='x64'
else
  echo "$red Sorry, there's no serverless binary installer available for $MACHINE_TYPE architecture. Please open request for it at Serverless GitHub repository.$reset"
  exit 1
fi

# Resolve profile
SHELLTYPE="$(basename "/$SHELL")"
if [ "$SHELLTYPE" = "bash" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    PROFILE="$HOME/.bashrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    PROFILE="$HOME/.bash_profile"
  fi
elif [ "$SHELLTYPE" = "zsh" ]; then
  PROFILE="$HOME/.zshrc"
elif [ "$SHELLTYPE" = "fish" ]; then
  PROFILE="$HOME/.config/fish/config.fish"
fi

if [ -z "$PROFILE" ]; then
  if [ -f "$HOME/.profile" ]; then
    PROFILE="$HOME/.profile"
  elif [ -f "$HOME/.bashrc" ]; then
    PROFILE="$HOME/.bashrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    PROFILE="$HOME/.bash_profile"
  elif [ -f "$HOME/.zshrc" ]; then
    PROFILE="$HOME/.zshrc"
  elif [ -f "$HOME/.config/fish/config.fish" ]; then
    PROFILE="$HOME/.config/fish/config.fish"
  else
    echo "$red Sorry, unable to resolve profile file. Binary cannot be installed.$reset"
    exit 1
  fi
fi

# Resolve latest tag
LATEST_TAG=`curl -L --silent https://api.github.com/repos/serverless/serverless/releases/latest 2>&1 | grep 'tag_name' | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+"`

# Dowload binary
BINARIES_DIR_PATH=$HOME/.serverless/bin
BINARY_PATH=$BINARIES_DIR_PATH/serverless
mkdir -p $BINARIES_DIR_PATH
echo " Downloading binary..."
curl -L -o $BINARY_PATH https://github.com/serverless/serverless/releases/download/$LATEST_TAG/serverless-$PLATFORM-$ARCH
chmod +x $BINARY_PATH

# Ensure aliases
ln -sf serverless $BINARIES_DIR_PATH/sls

# Add to $PATH
SOURCE_STR="export PATH=\"\$HOME/.serverless/bin:\$PATH\"\n"
if ! grep -q '.serverless/bin' "$PROFILE"; then
  if [[ $PROFILE == *"fish"* ]]; then
    command fish -c 'set -U fish_user_paths $fish_user_paths ~/.serverless/bin'
    printf "\n$yellow Added ~/.serverless/bin to fish_user_paths universal variable"
  else
    command printf "\n$SOURCE_STR" >> "$PROFILE"
    printf "\n$yellow Added the following to $PROFILE"
  fi

  echo ", if this isn't the profile of your current shell then please add the following to your correct profile:"
  echo " $SOURCE_STR$reset"
fi

$HOME/.serverless/bin/serverless binary-postinstall
