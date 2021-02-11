#!/bin/sh

# Use the GitHub API to find the latest release of the GitHub Action runner,
# then download and extract the tarball for that release.

set -eE -o pipefail

release_file=/tmp/latest-runner-release.json
releases_api=https://api.github.com/repos/actions/runner/releases/latest

echo "Fetching latest release from $releases_api"

if [ ! $GITHUB_PAT = '' ]; then
    # Set this to work around rate-limiting issues
    echo "GITHUB_PAT is set; using for GitHub API"
    auth_header="Authorization: token $GITHUB_PAT"
fi

curl -sSLf -H "$auth_header" -H 'Accept: application/json' -o $release_file $releases_api

latest_tag=$(jq -r '.tag_name' $release_file)
echo "Latest runner is ${latest_tag}"
echo $latest_tag >> ".RUNNER_VERSION"
rm $release_file

tag_without_v=$(echo $latest_tag | cut -c 2-)

os="linux"      # could be "win" or "osx"
arch="x64"      # for linux os, could be "arm" or "arm64"

runner_tar="actions-runner-${os}-${arch}-${tag_without_v}.tar.gz"
runner_url="https://github.com/actions/runner/releases/download/${latest_tag}/${runner_tar}"

set -x
curl -sSLf -O ${runner_url}
tar fxzp ${runner_tar}
rm ${runner_tar}
