# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/bazzite-dx:stable

### MODIFICATIONS
# Add Hyprland COPR for Fedora 44
RUN curl -Lo /etc/yum.repos.d/copr-hyprland.repo \
    "https://copr.fedorainfracloud.org/coprs/solopasha/hyprland/repo/fedora-44/solopasha-hyprland-fedora-44.repo"

# Install Hyprland and dependencies
RUN rpm-ostree install hyprland kitty wofi \
    && ostree container commit

# Run existing build scripts
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
RUN bootc container lint
