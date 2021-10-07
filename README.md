# OpenShift GitHub Actions Runners

[![Update Runner Images](https://github.com/redhat-actions/openshift-actions-runner/actions/workflows/update_images.yml/badge.svg)](https://github.com/redhat-actions/openshift-actions-runner/actions/workflows/update_images.yml)
[![Link checker](https://github.com/redhat-actions/openshift-actions-runner/actions/workflows/link_check.yml/badge.svg)](https://github.com/redhat-actions/openshift-actions-runner/actions/workflows/link_check.yml)

[![Tag](https://img.shields.io/github/v/tag/redhat-actions/openshift-actions-runner)](https://github.com/redhat-actions/openshift-actions-runner/tags)
[![Quay org](https://img.shields.io/badge/quay-redhat--github--actions-red)](https://quay.io/organization/redhat-github-actions)

This repository contains Containerfiles for building container images that act as [self-hosted GitHub Action runners](https://docs.github.com/en/free-pro-team@latest/actions/hosting-your-own-runners/about-self-hosted-runners) that work on OpenShift.

The [**OpenShift Actions Runner Chart**](https://github.com/redhat-actions/openshift-actions-runner-chart) is used to deploy these images into a cluster, and the [**OpenShift Actions Runner Installer**](https://github.com/redhat-actions/openshift-actions-runner-installer) is an Action to automate the chart install.

## Runners
1. The [**base runner**](./base) is based on Fedora. It is intended to have a fairly minimal tool set to keep the image size as small as possible. It has all the GitHub Actions Runner needs, plus a limited number of popular Unix command-line tools.
2. The [**buildah runner**](./buildah) extends the base runner to add `buildah` and `podman`. This runner requires permissions that are disabled for by default on OpenShift. See [the buildah image README](./buildah/#README.md) for details.
3. The [**K8s tools runner**](./k8s-tools) installs a set of CLIs used to work with Kubernetes.
4. The [**Node.js runner**](./node) includes a Node.js runtime.
5. The [**Java runner**](./java) includes a JDK and JRE.

The idea is that the base runner can be extended to build larger, more complex images that have additional capabilities. Refer to [Creating your own runner image](./base#creating-your-own-runner-image).

The images are hosted at [quay.io/redhat-github-actions](https://quay.io/redhat-github-actions/).

While these images are developed for and tested on OpenShift, they do not contain any OpenShift specific code and should be compatible with any Kubernetes platform.

## Installing into a cluster
Use the [**OpenShift Actions Runner Chart**](https://github.com/redhat-actions/openshift-actions-runner-chart) to deploy these runners into your cluster.

<a id="pat-guidelines"></a>
## Creating a Personal Access Token
To register themselves with GitHub, the runners require a [GitHub Personal Access Token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) (PAT) which has the `repo` permission scope. This is provided to the container through the `GITHUB_PAT` environment variable.
- The user who created the token must have administrator permission on the organization/repository the runner will be added to.
- If the runner will be for an organization, the token must also have the `admin:org` permission scope.
- [See an example](./pat-creation.png).

## Building your own runner image
See the [base image README](./base/#own-image).

## Running Locally
You can run the images locally to test and develop.

To launch and connect a runner to `redhat-actions/openshift-actions-runner` with the labels `local` and `podman`:
```sh
podman run \
    --env GITHUB_PAT=$GITHUB_PAT \
    --env GITHUB_OWNER=redhat-actions \
    --env GITHUB_REPOSITORY=openshift-actions-runner \
    --env RUNNER_LABELS="local,podman" \
    quay.io/redhat-github-actions/runner:latest
```

Or, to run a shell for debugging:
```sh
podman run -it --entrypoint=/bin/bash quay.io/redhat-github-actions/runner:latest
```

## Authenticating with a Runner Token
A Runner Token can be used as an alternative to PAT or GitHub App authentication.

Refer to [Authenticating with a Runner Token](./docs/runner-token.md).

<a id="enterprise-support"></a>

## GitHub Enterprise Support
You can use any of the runners on your GitHub Enterprise server by overriding `GITHUB_DOMAIN` in the environment, using `podman run --env` or using the [chart](https://github.com/redhat-actions/openshift-actions-runner-chart).

For example, if you set:
```
GITHUB_DOMAIN=github.mycompany.com
```

the runner entrypoint will then try and register itself with

```
https://github.mycompany.com/$GITHUB_OWNER/$GITHUB_REPOSITORY
```

and use the GitHub API at

```
https://github.mycompany.com/api/v3/
```

## Troubleshooting
If the containers crash on startup, it is usually because one of the environment variables is missing or misconfigured. Make sure to read the container logs carefully to make sure the variables' values are set as expected.

- If the container crashes with an HTTP 403 error, the `GITHUB_PAT` does not have the appropriate permissions. Refer to the [PAT guidelines](#pat-guidelines).
- If the container crashes with an HTTP 404 error, the `GITHUB_OWNER` or `GITHUB_REPOSITORY` is incorrect or misspelled.
    - This will also happen if a private repository is selected which the `GITHUB_PAT` does not have permission to view.

If you encounter any other issues, please [open an issue](https://github.com/redhat-actions/openshift-actions-runner/issues) and we will help you work through it.

## Credits
This repository builds on the work done in [bbrowning/github-runner](https://github.com/bbrowning/github-runner), which is forked from [SanderKnape/github-runner](https://github.com/SanderKnape/github-runner).
