FROM fedora:33

# Adapted from https://github.com/bbrowning/github-runner/blob/master/Dockerfile
RUN dnf -y upgrade --security && \
    dnf -y --setopt=skip_missing_names_on_install=False install \
    curl git jq hostname procps findutils && \
    dnf clean all

# The UID env var should be used in child dockerfiles.
ENV UID=1000
# ENV GID=0
ENV USERNAME="build"

# Create our user and their home directory
RUN useradd -m $USERNAME -u $UID
RUN usermod -G 0 $USERNAME
ENV HOME /home/${USERNAME}
WORKDIR /home/${USERNAME}

# Override these when creating the container.
ENV GITHUB_PAT ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV RUNNER_WORKDIR /home/${USERNAME}/_work
ENV RUNNER_LABELS ""

# Allow group 0 to modify these /etc/ files since on openshift, the dynamically-assigned user is always part of group 0.
# Also see uid.sh
RUN chmod g+w /etc/passwd && \
    touch /etc/sub{g,u}id && \
    chmod -v ug+rw /etc/sub{g,u}id

COPY --chown=${USERNAME}:0 get-runner-release.sh ./
RUN ./get-runner-release.sh
RUN ./bin/installdependencies.sh

# Set permissions so that we can allow the openshift-generated container user to access home and /etc/passwd.
# https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
RUN chown -R ${USERNAME}:0 /home/${USERNAME}/ && \
    chgrp -R 0 /home/${USERNAME}/ && \
    chmod -R g=u /home/${USERNAME}/

COPY --chown=${USERNAME}:0 entrypoint.sh uid.sh ./
# RUN chmod -v ug+x *.sh

USER $UID

ENTRYPOINT ./entrypoint.sh
