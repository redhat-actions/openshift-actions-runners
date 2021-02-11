#!/bin/sh

# Ensure that dynamically-assigned uid has an entry in /etc/passwd on container startup.

# https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
# https://www.openshift.com/blog/jupyter-on-openshift-part-6-running-as-an-assigned-user-id

set -eE -o pipefail

uid=$(id -u)
gid=$(id -g)
username=${USER_NAME:-default}

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "Creating passwd entry for $username"
    echo "${username}:x:${uid}:0:${username} user:${HOME}:/sbin/nologin" >> /etc/passwd
    echo -n "New passwd entry: "
    tail -n 1 /etc/passwd
  else
    echo "No write permission to /etc/passwd!" 1>&2
    exit 1
  fi
else
  echo "Current user already has passwd entry"
fi

echo "whoami=$(whoami)"
echo "groups=$(groups)"

set +x
if ! grep $username /etc/subuid &> /dev/null; then
  echo "Creating sub{u,g}id entries for $username with uid $uid and gid $gid"
  subuids_start=$(expr $uid + 1000)
  subgids_start=$(expr $gid + 1000)

  # Openshift allows a range of 10000 u/g IDs, so we have to stay under that limit.
  echo "${username}:${subuids_start}:65536" >> /etc/subuid
  echo "${username}:${subgids_start}:65536" >> /etc/subgid
else
  echo "subuid entry already exists for $username"
fi

# set -x
# tail -n +1 /etc/sub{u,g}id
