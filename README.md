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

## Running Locally without PAT

If you're not comfortable persisting a PAT with access to all of your repositories, it is also possible to manually generate a runner registration token and use that.

You can create a runner token with [the GitHub API](https://docs.github.com/en/rest/reference/actions#create-a-registration-token-for-an-organization) or through the repository or organization's Settings. Navigate to `Settings` > `Actions` > `Runners`, click `Add Runner`, and copy out the `--token` argument from the `config.sh` call.

Note that these tokens are only good for 60 minutes, so you must keep the local files created upon registration (after running `config.sh`) in order to be able to restart your runner. A similar process may be especially useful in Kubernetes, so that Pods can be recreated without manual intervention.

```sh
# Create volume to persist authentication and configuration
podman volume create runner
# Perform registration, and copy artifacts to volume
podman run \
    --env RUNNER_TOKEN=$RUNNER_TOKEN \
    --env GITHUB_OWNER=redhat-actions \
    --env GITHUB_REPOSITORY=openshift-actions-runner \
    --env RUNNER_LABELS="local,podman" \
    --rm -v runner:/persistence \
    --entrypoint='' \
    quay.io/redhat-github-actions/runner:latest \
    bash -c "./register.sh && cp -rT . /persistence"
# Run container with volume mounted over runner home directory
podman run \
    --rm -v runner:/home/runner \
    quay.io/redhat-github-actions/runner:latest
```

## Running with Github App Authentication

If you are able to use a Github App it is highly recommended over the PAT because you have greater control of the API permissions granted to it and you do not need a bot or service account.

### Setting up a Github App for Runner Registration

You can create a GitHub App for either your user account or any organization, below are the app permissions required for each supported type of runner:

_Note: Links are provided further down to create an app for your logged in user account or an organization with the permissions for all runner types set in each link's query string_

**Required Permissions for Repository Runners:**<br />
**Repository Permissions**

* Actions (read)
* Administration (read / write)
* Metadata (read)

**Required Permissions for Organization Runners:**<br />
**Repository Permissions**

* Actions (read)
* Metadata (read)

**Organization Permissions**
* Self-hosted runners (read / write)


_Note: All API routes mapped to their permissions can be found [here](https://docs.github.com/en/rest/reference/permissions-required-for-github-apps) if you wish to review_

---

**Setup Steps**

If you want to create a GitHub App for your account, open the following link to the creation page, enter any unique name in the "GitHub App name" field, and hit the "Create GitHub App" button at the bottom of the page.

- [Create GitHub Apps on your account](https://github.com/settings/apps/new?url=https://github.com/redhat-actions/openshift-actions-runners&webhook_active=false&public=false&administration=write&actions=read)

If you want to create a GitHub App for your organization, replace the `:org` part of the following URL with your organization name before opening it. Then enter any unique name in the "GitHub App name" field, and hit the "Create GitHub App" button at the bottom of the page to create a GitHub App.

- [Create GitHub Apps on your organization](https://github.com/organizations/:org/settings/apps/new?url=https://github.com/redhat-actions/openshift-actions-runners&webhook_active=false&public=false&administration=write&organization_self_hosted_runners=write&actions=read)

You will see an *App ID* on the page of the GitHub App you created. You will need the value of this App ID later.

Download the private key file by pushing the "Generate a private key" button at the bottom of the GitHub App page. This file will also be used later.

Go to the "Install App" tab on the left side of the page and install the GitHub App that you created for your account or organization.

When the installation is complete, you will be taken to a URL in one of the following formats, the last number of the URL will be used as the Installation ID later (For example, if the URL ends in `settings/installations/12345`, then the Installation ID is `12345`).

- `https://github.com/settings/installations/${INSTALLATION_ID}`
- `https://github.com/organizations/eventreactor/settings/installations/${INSTALLATION_ID}`

### Running Locally with Github App Authentication

You need to set the `GITHUB_APP_ID`, `GITHUB_APP_INSTALL_ID`, and `GITHUB_APP_PEM` env variables and pass them to your container. The easiest way to get the private key in the correct form is to copy paste it into the environment variable.

To launch and connect a runner to `redhat-actions/openshift-actions-runner` with the labels `local` and `podman`:

```sh
podman run \
    --env GITHUB_APP_ID \
    --env GITHUB_APP_INSTALL_ID \
    --env GITHUB_APP_PEM \
    --env GITHUB_OWNER=redhat-actions \
    --env GITHUB_REPOSITORY=openshift-actions-runner \
    --env RUNNER_LABELS="local,podman" \
    quay.io/redhat-github-actions/runner:latest
```

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

The Github App creation tutorial is heavily based on the excellent README in [ctions-runner-controller/actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller)
