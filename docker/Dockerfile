FROM archlinux:latest

RUN pacman -Syu --noconfirm bash coreutils grep findutils git base-devel sudo

COPY . /workspace/

# Run pacman-based install scripts as root
RUN bash /workspace/linux/arch/runs/02-packages.sh
RUN bash /workspace/linux/arch/runs/04-fonts.sh

# Create non-root user for AUR builds and runtime testing
RUN useradd -m -s /bin/bash testuser

# Grant testuser passwordless sudo
RUN echo "testuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/testuser \
    && chmod 0440 /etc/sudoers.d/testuser

# Run AUR scripts as testuser
USER testuser
RUN bash /workspace/linux/arch/runs/01-aur.sh
RUN bash /workspace/linux/arch/runs/03-aur-packages.sh
USER root

# Prepare home directory for dotfiles deployment
RUN mkdir -p /home/testuser/.claude /home/testuser/.config/opencode \
    && chown -R testuser:testuser /home/testuser/.claude /home/testuser/.config

RUN chown -R testuser:testuser /workspace

USER testuser
WORKDIR /workspace

ENTRYPOINT ["bash", "docker/test-entrypoint.sh"]
