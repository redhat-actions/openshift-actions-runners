ARG BASE_IMG=quay.io/redhat-github-actions/runner:latest
FROM $BASE_IMG AS java-runner

USER root

RUN dnf install -y java-11-openjdk-devel.x86_64

USER $UID
