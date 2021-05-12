#!/usr/bin/env bash

set -eEu -o pipefail

# Replace with your username. Don't push your dev images to redhat-github-actions.
REGISTRY=${RUNNERS_REGISTRY:-quay.io/tetchell}
TAG=${RUNNERS_TAG:-latest}

BASE_IMG=${REGISTRY}/runner:${TAG}
BUILDAH_IMG=${REGISTRY}/buildah-runner:${TAG}
K8S_TOOLS_IMG=${REGISTRY}/k8s-tools-runner:${TAG}

echo "Base img tag $BASE_IMG"

enabled() {
    [[ $1 == *$2* ]]
}

cd $(dirname $0)

if enabled "$*" base; then
    echo "Building base image..."
    docker build -f ./base/Containerfile -t $BASE_IMG ./base
fi

if enabled "$*" buildah; then
    echo "Building buildah image..."
    docker build -f ./buildah/Containerfile -t $BUILDAH_IMG ./buildah
fi
if enabled "$*" k8s; then
    echo "Building K8s image..."
    docker build -f ./k8s-tools/Containerfile -t $K8S_TOOLS_IMG ./k8s-tools
fi

if enabled "$*" push; then
    echo "Pushing..."
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
