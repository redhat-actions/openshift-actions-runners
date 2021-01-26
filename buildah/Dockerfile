ARG BASE_IMG=quay.io/redhat-github-actions/runner:latest

FROM $BASE_IMG AS buildah-runner

# ARG BUILDAH_RPM=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_7/x86_64/buildah-1.18.0-2.el7.x86_64.rpm

# Must match base dockerfile - should be shared
ARG UID=1001
USER root

# Some complex config is required to allow buildah to run in a nonprivileged container.
# Most of below is from https://github.com/containers/buildah/blob/master/contrib/buildahimage/centos7/Dockerfile
# Also see https://github.com/containers/buildah/issues/1011

RUN dnf -y install shadow-utils xz slirp4netns buildah podman --exclude container-selinux --exclude fuse-overlayfs && \
    dnf clean all

ADD https://raw.githubusercontent.com/containers/buildah/master/contrib/buildahimage/stable/containers.conf /etc/containers/
RUN chgrp -R 0 /etc/containers/ && \
    chmod -R a+r /etc/containers/

# prevents errors from failing to log using systemd https://github.com/containers/podman/issues/4325#issuecomment-570650857
# See https://github.com/containers/common/blob/master/docs/containers.conf.5.md for valid configurations
RUN echo 'events_logger = "file"' >> /etc/containers/containers.conf

# This should allow buildah/podman
RUN echo "user.max_user_namespaces=15000" > /etc/sysctl.d/userns.conf

# Fuse storage does not work in k8s. We have to use vfs.
ENV STORAGE_DRIVER=vfs

# These are used to enable fuse storage which is used for buildah-in-docker, but doesn't work in k8s.
# If trying to use fuse, also note it's excluded from the buildah installation above.
# RUN sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' /etc/containers/storage.conf
# RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers; touch /var/lib/shared/overlay-images/images.lock; touch /var/lib/shared/overlay-layers/layers.lock

# Set up environment variables to note that this is
# not starting with usernamespace and default to
# isolate the filesystem with chroot.
ENV _BUILDAH_STARTED_IN_USERNS="" BUILDAH_ISOLATION=chroot

ENV RUNNER_LABELS="${RUNNER_LABELS},container-tools"

# ENTRYPOINT /bin/sh

# Numeric user ID is required to enforce runAsNonRoot security policy
USER $UID
