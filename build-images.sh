#!/usr/bin/env bash

set -eEu -o pipefail

# Replace with your username. Don't push your dev images to redhat-github-actions.
REGISTRY=${RUNNERS_REGISTRY:-quay.io/tetchell}
TAG=${RUNNERS_TAG:-latest}

BASE_IMG=${REGISTRY}/runner:${TAG}
BUILDAH_IMG=${REGISTRY}/buildah-runner:${TAG}
K8S_TOOLS_IMG=${REGISTRY}/k8s-tools-runner:${TAG}

enabled() {
    [[ $1 == *$2* ]]
}

cd $(dirname $0)

echo "Building base image..."
docker build ./base -f ./base/Dockerfile -t $BASE_IMG

if enabled "$*" buildah; then
    echo "Building buildah image..."
    docker build ./buildah -f ./buildah/Dockerfile -t $BUILDAH_IMG
fi
if enabled "$*" k8s; then
    echo "Building K8s image..."
    docker build ./k8s-tools -f ./k8s-tools/Dockerfile -t $K8S_TOOLS_IMG
fi

if enabled "$*" push; then
    docker push $BASE_IMG

    if enabled "$*" buildah; then
        docker push $BUILDAH_IMG
    fi
    if enabled "$*" k8s; then
        docker push $K8S_TOOLS_IMG
    fi
else
    echo "Not pushing. Pass 'push' to push"
fi

echo "$BASE_IMG"
if enabled "$*" buildah; then
    echo "$BUILDAH_IMG"
fi
if enabled "$*" k8s; then
    echo "$K8S_TOOLS_IMG"
fi

cd - > /dev/null
