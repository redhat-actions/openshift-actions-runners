FROM fedora:33

# Adapted from https://github.com/bbrowning/github-runner/blob/master/Dockerfile
RUN dnf -y --setopt=skip_missing_names_on_install=False install \
    curl git jq hostname procps findutils && \
    dnf clean all

ARG UID=1001
# The UID env var should be used in child dockerfiles.
ENV UID=$UID
ARG USER=runner
ENV USER_NAME=$USER
ARG RUNNER_WORKDIR=/home/${USER}/_work

# Override these when creating the container.
ENV GITHUB_PAT ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV RUNNER_WORKDIR $RUNNER_WORKDIR
ENV RUNNER_LABELS ""

# Create our user and their home directory
RUN useradd -m $USER -u $UID
RUN usermod -G 0 $USER
ENV HOME /home/$USER
WORKDIR /home/$USER

# Allow group 0 to modify these /etc/ files since on openshift, the dynamically-assigned user is always part of group 0.
# Also see uid.sh
RUN chmod g+w /etc/passwd && \
    touch /etc/subguid && \
    touch /etc/subuid && \
    chmod ug+rw /etc/sub{u,g}id

COPY --chown=${USER}:0 get-runner-release.sh ./
RUN ./get-runner-release.sh
RUN ./bin/installdependencies.sh

# Set permissions so that we can allow the openshift-generated container user to access home and /etc/passwd.
# https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
RUN chown -R ${USER}:0 /home/$USER/ && \
    chgrp -R 0 /home/$USER/ && \
    chmod -R g=u /home/$USER/

COPY --chown=${USER}:0 entrypoint.sh uid.sh ./
RUN chmod -v ug+x *.sh

USER $UID:0

ENTRYPOINT ./entrypoint.sh
