#!/bin/sh
# Based on https://github.com/bbrowning/github-runner/blob/master/entrypoint.sh

./uid.sh > /tmp/uid.sh.log

set -eE

CREDS_FILE="${PWD}/.credentials"

# Assume registration artifacts have been persisted from a previous start
# if no PAT or TOKEN is provided, and simply attempt to start.
if [ -n "${GITHUB_PAT:-}" ] || [ -n "${RUNNER_TOKEN:-}" ] || [ -n "${GITHUB_APP_ID:-}" ]; then
    source ./register.sh
elif [ -e "${CREDS_FILE}" ]; then
    echo "No GITHUB_PAT or RUNNER_TOKEN provided. Using existing credentials file ${CREDS_FILE}."
else
    echo "No saved credentials found in ${CREDS_FILE}."
    echo "Fatal: GITHUB_PAT or RUNNER_TOKEN must be set in the environment."
    exit 1
fi

if [ -n "${GITHUB_PAT:-}" ]; then
    trap 'remove; exit 130' INT
    trap 'remove; exit 143' TERM
elif [ -n "${GITHUB_APP_ID:-}" ]; then
    trap 'remove_github_app; exit 130' INT
    trap 'remove_github_app; exit 143' TERM
else
    trap 'exit 130' INT
    trap 'exit 143' TERM
fi

set -x
./bin/runsvc.sh --once &
svc_pid=$!

wait $svc_pid
