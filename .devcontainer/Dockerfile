# Best image for Tauri Android testing in GitHub Codespaces.
#
# mcr.microsoft.com/devcontainers/base:ubuntu-22.04 is chosen because:
#  - Ubuntu 22.04 LTS is the most stable base supported by all required toolchains
#    (Rust, Android SDK/NDK, JDK 17, Node.js).
#  - The devcontainers/base variant is lean yet includes the devcontainer CLI
#    helpers, non-root user setup, and common utilities out of the box.
#  - Compared to the language-specific variants (rust, java, node) it avoids
#    pinning to a single language's defaults while still letting us compose
#    exactly the versions we need via devcontainer Features and manual steps.
#  - Ubuntu 22.04 ships glibc 2.35 which is required by recent Android NDK
#    host binaries.
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# ── Arguments & versions ──────────────────────────────────────────────────────
ARG ANDROID_COMPILE_SDK=34
ARG ANDROID_BUILD_TOOLS=34.0.0
# NDK r26d is the version recommended by the Tauri Android documentation.
ARG ANDROID_NDK_VERSION=26.3.11579264
ARG ANDROID_CMDLINE_TOOLS_VERSION=11076708

# ── System dependencies ───────────────────────────────────────────────────────
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        # Build essentials
        build-essential \
        curl \
        wget \
        unzip \
        zip \
        file \
        pkg-config \
        libssl-dev \
        libgtk-3-dev \
        libwebkit2gtk-4.0-dev \
        libayatana-appindicator3-dev \
        librsvg2-dev \
        # Required by Android emulator / ADB
        libglib2.0-0 \
        libnss3 \
        # Java 17 (required by Android SDK tools)
        openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# ── Android SDK ───────────────────────────────────────────────────────────────
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && wget -q \
       "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS_VERSION}_latest.zip" \
       -O /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools-extracted \
    && mv /tmp/cmdline-tools-extracted/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools-extracted

ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/ndk/${ANDROID_NDK_VERSION}:${PATH}"

# Accept SDK licenses and install required packages
RUN yes | sdkmanager --licenses > /dev/null 2>&1 \
    && sdkmanager \
        "platform-tools" \
        "platforms;android-${ANDROID_COMPILE_SDK}" \
        "build-tools;${ANDROID_BUILD_TOOLS}" \
        "ndk;${ANDROID_NDK_VERSION}"

ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/${ANDROID_NDK_VERSION}
ENV NDK_HOME=${ANDROID_NDK_HOME}

# ── Rust (via rustup) ─────────────────────────────────────────────────────────
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH="${CARGO_HOME}/bin:${PATH}"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --no-modify-path --default-toolchain stable \
    && chmod -R a+w ${RUSTUP_HOME} ${CARGO_HOME}

# Android cross-compilation targets required by Tauri for Android
RUN rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi \
    i686-linux-android \
    x86_64-linux-android

# ── Tauri CLI & cargo-ndk ─────────────────────────────────────────────────────
RUN cargo install tauri-cli --locked \
    && cargo install cargo-ndk --locked

# ── Node.js (LTS via nvm) ─────────────────────────────────────────────────────
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=lts/*

RUN mkdir -p ${NVM_DIR} \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . ${NVM_DIR}/nvm.sh \
    && nvm install ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION} \
    && nvm use default \
    && npm install -g nx@latest \
    # Create a stable symlink so PATH can reference a fixed location
    && ln -sf "$(. ${NVM_DIR}/nvm.sh && nvm which default)" /usr/local/bin/node \
    && ln -sf "$(dirname "$(. ${NVM_DIR}/nvm.sh && nvm which default)")/npm" /usr/local/bin/npm \
    && ln -sf "$(dirname "$(. ${NVM_DIR}/nvm.sh && nvm which default)")/nx" /usr/local/bin/nx

# Make nvm available for interactive shells (bash and zsh)
RUN echo ". ${NVM_DIR}/nvm.sh" >> /etc/bash.bashrc \
    && echo ". ${NVM_DIR}/nvm.sh" >> /etc/zsh/zshrc 2>/dev/null || true

# ── Ownership ─────────────────────────────────────────────────────────────────
# Allow the default non-root devcontainer user (UID 1000) to use the SDK
RUN chmod -R a+rX ${ANDROID_HOME}
