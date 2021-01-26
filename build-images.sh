#!/usr/bin/env bash

set -eE -o pipefail

# Replace with your username. Don't push your dev images to redhat-github-actions.
REGISTRY=${RUNNERS_REGISTRY:-quay.io/tetchell}
TAG=${RUNNERS_TAG:-latest}

BASE_IMG=${REGISTRY}/runner:${TAG}
BUILDAH_IMG=${REGISTRY}/buildah-runner:${TAG}

set -x

cd $(dirname $0)

docker build ./base -f ./base/Dockerfile -t $BASE_IMG
docker build ./buildah -f ./buildah/Dockerfile -t $BUILDAH_IMG

set +x

if [[ $1 == "push" ]]; then
    set -x
    docker push $BASE_IMG
    docker push $BUILDAH_IMG
else
    echo "Not pushing. Set \$1 to 'push' to push"
fi

echo "$BASE_IMG"
echo "$BUILDAH_IMG"

cd - > /dev/null
