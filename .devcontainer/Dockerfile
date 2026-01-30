# ------------------------------------------------------------------------------
# 🐳 OpenFactory Python Devcontainer
#
# This image is used as a development container for OpenFactory projects.
# It provides a minimal Python environment, creates a vscode user,
# configures the shell prompt like official devcontainers, and installs
# essential tools and Python packages for development.
#
# Key Features:
#   - Python version configurable via build arg `PYTHON_BASE_IMAGE`
#     (default: python:3.13-slim-bookworm)
#   - Non-root 'vscode' user with sudo privileges
#   - Dynamic Git branch prompt with colors in Bash
#   - Installs essential tools: git, curl, yq
#   - Upgrades pip, setuptools, and wheel for smooth Python package installs
#   - Ready for use with VS Code devcontainers
# 
# For local builds:
#     docker build --build-arg PYTHON_BASE_IMAGE=python:3.14-slim-bookworm \
#                  -t openfactoryio/devcontainer:latest \
#                  -f Dockerfile .
# ------------------------------------------------------------------------------

# Python version (with slim variant)
ARG PYTHON_BASE_IMAGE=python:3.13-slim-bookworm
FROM ${PYTHON_BASE_IMAGE}

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Create vscode user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update && apt-get install -y sudo git curl yq \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set container environment variables
ENV USER=$USERNAME
ENV _CONTAINER_USER_HOME=/home/$USERNAME
ENV PATH=/home/$USERNAME/.local/bin:$PATH

USER $USERNAME
WORKDIR $_CONTAINER_USER_HOME

# Mimic Microsoft-style .bashrc to enable dynamic git branch prompt with colors
RUN echo 'parse_git_branch() { git branch 2>/dev/null | grep "^\*" | sed "s/* //"; }' >> $_CONTAINER_USER_HOME/.bashrc \
    && echo 'export PS1="\[\033[01;32m\]\u\[\033[00m\] ➜ \[\033[01;34m\]\w\[\033[00m\]\[\033[01;31m\] (\$(parse_git_branch))\[\033[00m\] $ "' >> $_CONTAINER_USER_HOME/.bashrc

# Upgrade pip
RUN pip install --upgrade pip setuptools wheel

# Default shell to bash
ENV SHELL=/bin/bash
