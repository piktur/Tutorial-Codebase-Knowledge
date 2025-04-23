# syntax=docker.io/docker/dockerfile-upstream:1.14.0-labs

# Declare global args before base image instruction; user will be renamed according to overrides
# declared in build-args.
ARG TARGETARCH=arm64
ARG USERNAME=appuser \
    USER_UID=1000 \
    USER_GID=1000

ARG PYTHON_VERSION=3.12

FROM ghcr.io/piktur/finance/devcontainers/base:debian

ARG USERNAME \
    USER_UID \
    USER_GID
ARG TARGETARCH
ARG PYTHON_VERSION

USER root
WORKDIR /

ENV HOME=/home/${USERNAME}
ENV UV_CACHE_DIR=/.cache/uv \
    # @see https://docs.astral.sh/uv/guides/integration/docker/#caching
    UV_LINK_MODE=copy
ENV PATH="${HOME}/.local/bin:$PATH"

# @note The build cache is mounted to reduce image size.
# You MUST mount the uv cache volume to UV_CACHE_DIR path at runtime.
RUN --mount=type=cache,target=${UV_CACHE_DIR} \
    --mount=type=bind,source=./,target=/app \
    uv sync \
        --compile-bytecode \
        --python ${PYTHON_VERSION} \
        --script /app/main.py

WORKDIR /app

USER ${USERNAME}
