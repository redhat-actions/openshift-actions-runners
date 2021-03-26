ARG BASE_IMG=quay.io/redhat-github-actions/runner:latest
FROM $BASE_IMG AS buildah-runner

USER root

# https://github.com/containers/buildah/blob/master/docs/tutorials/05-openshift-rootless-bud.md
# https://github.com/containers/buildah/blob/master/contrib/buildahimage/stable/Dockerfile
# https://github.com/containers/buildah/issues/1011
# https://github.com/containers/buildah/issues/3053

RUN dnf -y install xz slirp4netns buildah podman fuse-overlayfs --exclude container-selinux && \
    dnf -y reinstall shadow-utils && \
    dnf clean all

ENV BUILDAH_ISOLATION=chroot
ENV BUILDAH_LAYERS=true

ADD https://raw.githubusercontent.com/containers/buildah/master/contrib/buildahimage/stable/containers.conf /etc/containers/

RUN chgrp -R 0 /etc/containers/ && \
    chmod -R a+r /etc/containers/ && \
    chmod -R g+w /etc/containers/

# Use VFS since fuse does not work
# https://github.com/containers/buildah/blob/master/vendor/github.com/containers/storage/storage.conf
RUN mkdir -vp /home/${USERNAME}/.config/containers && \
    printf '[storage]\ndriver = "vfs"\n' > /home/${USERNAME}/.config/containers/storage.conf && \
    chown -Rv ${USERNAME} /home/${USERNAME}/.config/

USER $UID
