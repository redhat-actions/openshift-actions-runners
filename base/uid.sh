#!/bin/sh

# Ensure that dynamically-assigned uid has an entry in /etc/passwd on container startup.

# https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
# https://www.openshift.com/blog/jupyter-on-openshift-part-6-running-as-an-assigned-user-id

set -eEu

uid=$(id -u)
gid=$(id -g)
username=${USERNAME:-default}

echo "Current user has ID ${uid} and GID ${gid}"

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "Creating passwd entry for $username"
    echo "${username}:x:${uid}:0:${username} user:${HOME}:/sbin/nologin" >> /etc/passwd
    echo -n "New passwd entry: "
    tail -n 1 /etc/passwd
  else
    echo "No write permission to /etc/passwd!" 1>&2
  fi
else
  echo "User already has passwd entry"
fi

echo "whoami=$(whoami)"
echo "groups=$(groups 2>/dev/null)"

set +x
echo "Creating sub{u,g}id entries for $username"
subuids_start=$(expr $uid + 1000)
subgids_start=$(expr $gid + 1000)

# Do not allocate too many.
# https://github.com/containers/buildah/issues/3053
no_subids=50000

echo "${username}:${subuids_start}:${no_subids}" | tee /etc/subuid
echo "${username}:${subgids_start}:${no_subids}" | tee /etc/subgid

# set -x
# tail -n +1 /etc/sub{u,g}id
