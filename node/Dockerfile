ARG BASE_IMG=quay.io/redhat-github-actions/runner:latest
FROM $BASE_IMG AS node-runner

USER root

# https://nodejs.org/en/download/package-manager/#centos-fedora-and-red-hat-enterprise-linux
# 14 is LTS
RUN dnf module install -y nodejs:14/default

USER $UID
