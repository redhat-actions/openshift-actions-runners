ARG BASE_IMG=quay.io/redhat-github-actions/runner:latest
FROM $BASE_IMG AS buildah-runner

USER root

# Some complex config is required to allow buildah to run in a nonprivileged container.
# https://github.com/containers/buildah/blob/master/docs/tutorials/05-openshift-rootless-bud.md
# https://github.com/containers/buildah/blob/master/contrib/buildahimage/stable/Dockerfile
# https://github.com/containers/buildah/issues/1011

RUN dnf -y install shadow-utils xz slirp4netns buildah podman fuse-overlayfs --exclude container-selinux && \
    dnf clean all

ENV BUILDAH_ISOLATION=chroot

ADD https://raw.githubusercontent.com/containers/buildah/master/contrib/buildahimage/stable/containers.conf /etc/containers/

# ADD https://raw.githubusercontent.com/containers/buildah/master/contrib/buildahimage/stable/containers.conf /etc/containers/
RUN chgrp -R 0 /etc/containers/ && \
    chmod -R a+r /etc/containers/ && \
    chmod -R g+w /etc/containers/
    # echo "user.max_user_namespaces=65536" > /etc/sysctl.d/userns.conf && \
    # prevents errors from failing to log using systemd https://github.com/containers/podman/issues/4325#issuecomment-570650857
    # See https://github.com/containers/common/blob/master/docs/containers.conf.5.md for valid configurations
    # printf '[engine]\nevents_logger = "file"\n' >> /etc/containers/containers.conf
    # printf 'events_logger = "file"\n' >> /etc/containers/containers.conf

# Adjust storage.conf to enable Fuse storage.
RUN chmod 644 /etc/containers/containers.conf; sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' /etc/containers/storage.conf
RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers /var/lib/shared/vfs-images /var/lib/shared/vfs-layers; touch /var/lib/shared/overlay-images/images.lock; touch /var/lib/shared/overlay-layers/layers.lock; touch /var/lib/shared/vfs-images/images.lock; touch /var/lib/shared/vfs-layers/layers.lock

# Use VFS since fuse does not work
# https://github.com/containers/buildah/blob/master/vendor/github.com/containers/storage/storage.conf
RUN mkdir -vp /home/${USERNAME}/.config/containers && \
    printf '[storage]\ndriver = "vfs"\n' > /home/${USERNAME}/.config/containers/storage.conf && \
    chown -Rv ${USERNAME} /home/${USERNAME}/.config/

RUN printf "${USERNAME}:2000:50000\n" > /etc/subuid
RUN printf "${USERNAME}:2000:50000\n" > /etc/subgid

USER $UID
