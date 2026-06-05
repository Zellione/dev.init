FROM archlinux:latest

RUN pacman -Syu --noconfirm bash coreutils grep findutils

RUN useradd -m -s /bin/bash testuser

RUN mkdir -p /home/testuser/.claude /home/testuser/.config/opencode \
    && chown -R testuser:testuser /home/testuser/.claude /home/testuser/.config

WORKDIR /workspace
COPY . /workspace/
RUN chown -R testuser:testuser /workspace

USER testuser
WORKDIR /workspace

ENTRYPOINT ["bash", "docker/test-entrypoint.sh"]
