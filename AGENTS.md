# AGENTS.md – nx-tauri-tool

This file documents the AI-agent / Copilot setup used in this repository and
explains the decisions made when configuring the GitHub Codespaces devcontainer
for Tauri Android development.

---

## Devcontainer base image decision

**Question:** For Tauri Android testing in Codespaces, which
`mcr.microsoft.com/devcontainers/` image is best?

**Answer:** `mcr.microsoft.com/devcontainers/base:ubuntu-22.04`

### Why not the other variants?

| Image | Why it was not chosen |
|---|---|
| `mcr.microsoft.com/devcontainers/rust` | Pins a Rust version; does not include Android SDK, NDK, or JDK. |
| `mcr.microsoft.com/devcontainers/java:17` | Great for Java-only projects; lacks Rust and Android NDK host tools. |
| `mcr.microsoft.com/devcontainers/javascript-node` | No Rust, no Android SDK. |
| `mcr.microsoft.com/devcontainers/universal` | Very large (multi-GB); includes many unused runtimes; slow to start in Codespaces. |
| `mcr.microsoft.com/devcontainers/base:debian` | Debian 11 ships glibc 2.31 which is below the glibc 2.35 required by Android NDK r26+ binaries on the host. |

### Why `base:ubuntu-22.04`?

1. **glibc 2.35** – required by Android NDK r26d host binaries (`clang`,
   `llvm-strip`, etc.).
2. **`openjdk-17-jdk`** is available in the Ubuntu 22.04 official apt
   repository – JDK 17 is the minimum required by Android SDK build-tools 34.
3. **Lean but complete** – the `base` variant is significantly smaller than
   `universal` while still providing the devcontainer user/group helpers,
   common CLI tools, and `git`.
4. **Composable** – Rust, Android SDK, NDK, and Node.js are layered on top via
   `RUN` steps in `.devcontainer/Dockerfile`, giving full control over exact
   versions needed by Tauri.

---

## Installed toolchain summary

| Tool | Version / Source |
|---|---|
| Base OS | Ubuntu 22.04 LTS |
| JDK | OpenJDK 17 (apt) |
| Android SDK | API 34, build-tools 34.0.0 (sdkmanager) |
| Android NDK | r26d / `26.3.11579264` (sdkmanager) |
| Rust | stable (rustup) |
| Android Rust targets | `aarch64-linux-android`, `armv7-linux-androideabi`, `i686-linux-android`, `x86_64-linux-android` |
| cargo-ndk | latest (cargo install) |
| Tauri CLI | latest stable (cargo install) |
| Node.js | LTS (nvm) |
| NX | latest (npm) |

---

## Agent instructions

When assisting with this repository, AI agents should:

1. **Prefer `cargo tauri android`** commands for Android-related builds and
   tests.
2. **Use `cargo ndk`** for fine-grained cross-compilation control.
3. **Not suggest Android emulator** workflows inside Codespaces – the
   environment has no GPU/KVM access. Suggest Firebase Test Lab or a physical
   device over ADB TCP instead.
4. **Keep the devcontainer Dockerfile minimal** – only add packages that are
   strictly required by Tauri or the Android toolchain.
5. **Follow NX plugin conventions** – executors and generators go under `src/`,
   and all public APIs must be exported from `index.ts`.
