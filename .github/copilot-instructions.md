# Copilot Instructions – nx-tauri-tool

## Project purpose
`nx-tauri-tool` is an NX plugin / toolset that wires Tauri into an NX monorepo,
including support for **Tauri Android** builds and tests run inside GitHub
Codespaces.

---

## Devcontainer & environment

### Base image choice
The devcontainer is built on top of:

```
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04
```

**Why this image?**

| Criterion | Rationale |
|---|---|
| Stability | Ubuntu 22.04 LTS (Jammy) is supported until 2027 and is the minimum glibc (2.35) required by Android NDK r26+ host binaries. |
| Flexibility | The `base` variant does not pin a language toolchain, allowing us to compose exactly the versions needed for Rust + Android + Node.js. |
| Devcontainer helpers | The Microsoft `devcontainers/base` image already ships the non-root `vscode` user, `git`, `zsh`, common CLI utilities, and the devcontainer CLI hooks. |
| Alternative considered | `mcr.microsoft.com/devcontainers/rust` – rejected because it pins a Rust version and doesn't include the Android SDK setup. |

### Key toolchains installed
- **Rust** (stable, via rustup) with Android targets:
  `aarch64-linux-android`, `armv7-linux-androideabi`, `i686-linux-android`,
  `x86_64-linux-android`
- **Android SDK** (API 34, build-tools 34.0.0)
- **Android NDK** r26d (`26.3.11579264`) – recommended by Tauri documentation
- **JDK 17** (`openjdk-17-jdk`) – minimum required by Android SDK tools
- **Node.js** LTS (via nvm) + **NX** CLI

---

## Android testing workflow in Codespaces

Because Codespaces does not expose a display or hardware GPU, Android *emulator*
tests are not feasible directly. Recommended approaches:

1. **Physical device over ADB TCP/IP** – connect a physical Android device on
   the same network and forward the port.
2. **Firebase Test Lab** – build the `.apk` / `.aab` in Codespaces, upload to
   Firebase Test Lab, and run the test suite in the cloud.
3. **Headless instrumented tests** – run unit tests with `cargo test` using the
   Android cross-compilation target and a host-side test runner.

---

## Coding conventions
- Use **TypeScript** for all NX plugin code.
- Use **Rust** (stable) for Tauri backend code.
- Follow NX plugin conventions: executors in `src/executors/`, generators in
  `src/generators/`.
- Android-specific Tauri configuration lives under `src-tauri/gen/android/`.
- Do not commit `node_modules/`, `dist/`, `target/`, or `*.apk`/`*.aab`
  artefacts.

---

## Useful commands

```bash
# Build the Tauri Android APK (inside devcontainer)
cargo tauri android build

# Run Tauri Android in development mode (requires connected device)
cargo tauri android dev

# Run NX targets
nx run <project>:<target>

# Cross-compile a specific Rust target
cargo ndk -t arm64-v8a build --release
```
