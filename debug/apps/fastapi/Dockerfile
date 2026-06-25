# ------------------------------------------------------------------------------
# 🐳 Dockerfile for FastAPI-Demo-App
#
# build:
#   docker build -t demo-fastapi-app .
# ------------------------------------------------------------------------------

FROM python:3.12-slim

# Arguments for non-root user creation
ARG UNAME=demo-app
ARG UID=1200
ARG GID=1200

# Arguments for version management
ARG VERSION=dev
ARG OFA_VERSION=main

# Install git and create a non-root user and group
RUN apt-get update && apt-get install -y git \
    && groupadd --gid $GID $UNAME \
    && useradd --create-home --uid $UID --gid $GID $UNAME \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy application code
COPY . .

# Install dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir \
       "openfactory[fastapi] @ git+https://github.com/openfactoryio/openfactory-core.git@${OFA_VERSION}"

# Change ownership to the non-root user
RUN chown -R $UNAME:$UNAME /app

# Set environment variables
ENV APPLICATION_VERSION=${VERSION}
ENV PYTHONUNBUFFERED=1

# Switch to non-root user
USER $UNAME

# Command to run the app
ENTRYPOINT ["python", "src/app.py"]
