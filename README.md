# OpenShift GitHub Actions Runner

[![Update Runner Images](https://github.com/redhat-actions/openshift-actions-runner/workflows/Update%20Runner%20Images/badge.svg)](https://github.com/redhat-actions/openshift-actions-runner/actions)

[![Tag](https://img.shields.io/github/v/tag/redhat-actions/openshift-actions-runner)](https://github.com/redhat-actions/openshift-actions-runner/tags)
[![Quay org](https://img.shields.io/badge/quay-redhat--github--actions-red)](https://quay.io/organization/redhat-github-actions)

This repository contains Dockerfiles for building container images that act as [self-hosted GitHub Action runners](https://docs.github.com/en/free-pro-team@latest/actions/hosting-your-own-runners/about-self-hosted-runners) that work on OpenShift.

The [**OpenShift Action Runner Chart**](https://github.com/redhat-actions/openshift-actions-runner-chart) is used to deploy these images into a cluster.

See [`base/`](./base) for the base runner.

See [`buildah/`](./buildah) for a Dockerfile which builds on the base runner to add buildah and podman [with caveats](./buildah/README.md).

The idea is that the base runner can be extended to build larger, more complex images that have additional capabilities.

For example, the buildah runner extends the base runner to add container tools capabilities (namely, `buildah` and `podman`).

The images are hosted at [quay.io/redhat-github-actions](https://quay.io/redhat-github-actions/).

## Installing into a cluster
Use the [**OpenShift Actions Runner Chart**](https://github.com/redhat-actions/openshift-actions-runner-chart) to deploy these runners into your cluster.

## Creating a Personal Access Token
<a id="pat-guidelines"></a>
To register themselves with GitHub, the runners require a [GitHub Personal Access Token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) (PAT) which has the `repo` permission scope. This is provided to the container through the `GITHUB_PAT` environment variable.
- The user who created the token must have administrator permission on the organization/repository the runner will be added to.
- If the runner will be for an organization, the token must also have the `admin:org` permission scope.
- [See an example](./pat-creation.png).

## Creating your own runner image

You can create your own runner image based on this one, and install any runtimes and tools your workflows need.

1. Create your own Dockerfile, with `FROM quay.io/redhat-github-actions/runner:<tag>`.
2. Edit the Dockerfile to install and set up your tools, environment, etc. Do not override the `ENTRYPOINT`.
3. Build and push your new runner image.
4. Install [OpenShift Action Runner Chart](https://github.com/redhat-actions/openshift-actions-runner-chart) but set the value `runnerImage` to your image, and `runnerTag` to your tag.

## Running Locally
You can run the images locally to test and develop.

To launch and connect a runner to `redhat-actions/openshift-actions-runner` with the labels `local` and `docker`:
```sh
docker run \
    --env GITHUB_OWNER=redhat-actions \
    --env GITHUB_REPOSITORY=openshift-actions-runner \
    --env GITHUB_PAT=$GITHUB_PAT \
    --env RUNNER_LABELS="local,docker" \
    quay.io/redhat-github-actions/runner:v1.0.0
```

Or, to run a shell for debugging:
```sh
docker run -it --entrypoint=/bin/bash quay.io/redhat-github-actions/runner:v1.0.0
```

## Credits
This repository builds on the work done in [bbrowning/github-runner](https://github.com/bbrowning/github-runner), which is forked from [SanderKnape/github-runner](https://github.com/SanderKnape/github-runner).
