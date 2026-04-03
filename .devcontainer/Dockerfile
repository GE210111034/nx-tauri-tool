FROM mcr.microsoft.com/devcontainers/base:ubuntu24.04

RUN git config --system codespaces-theme.hide-status 1

USER root
RUN echo 'export DISPLAY="${DISPLAY:-:1}"' >> /root/.bashrc
CMD ["sleep", "infinity"]
