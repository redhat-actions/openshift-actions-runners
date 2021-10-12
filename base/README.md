# Base Actions Runner

[![Quay org](https://img.shields.io/badge/quay-redhat--github--actions%2Frunner-red)](https://quay.io/repository/redhat-github-actions/runner)

The base actions runner is meant to be minimal. It is build from [`fedora:33`](https://hub.docker.com/_/fedora), and contains the [GitHub Actions Runner](https://github.com/actions/runner/) and all its dependencies. At image build time, the latest runner version [is downloaded](./get-runner-release.sh), and the runner self-updates when it is connected to GitHub.

On OpenShift, containers run as a dynamically assigned user ID You can read about this on [the OpenShift blog](https://www.openshift.com/blog/a-guide-to-openshift-and-uids). This image contains logic to assign that user ID to the `runner` user and make sure the home directory and other required files are have the necessary permissions.

The [`entrypoint.sh`](./entrypoint.sh) acquires a GitHub Self Hosted Runner token using your GitHub PAT. The token is used to register the runner with GitHub, and connect to start listening for jobs on the organization or repository you specify.

Some basic CLI tools are installed in addition to what's in the parent Fedora image.

- `curl`
- `findutils` (`find`)
- `git`
- `hostname`
- `jq`
- `openssl`
- `procps` (`ps`, `pgrep`)
- `which`

<a id="own-image"></a>
## Building your own runner image

You can create your own runner image based on this one, and install any runtimes and tools your workflows need.

1. Create your own Containerfile, with `FROM quay.io/redhat-github-actions/runner:<tag>`.
2. Edit the Containerfile to install and set up your tools, environment, etc.
    - If you have to use root in your Containerfile, use `USER root` and convert back to `USER $UID` before the end of the Containerfile.
    - The `UID` environment variable is set in the base Containerfile.
    - Do not override the `ENTRYPOINT`.
3. Build and push your new runner image.
4. Install the [OpenShift Action Runner Chart](https://github.com/redhat-actions/openshift-actions-runner-chart). Set the value `runnerImage` to your image, and `runnerTag` to your tag.

Remember to pull the base image before running the container build to make sure you are building from an up-to-date image.

For example, one could build a runner image that includes a Node runtime in just four lines.
```Dockerfile
FROM quay.io/redhat-github-actions/runner:latest as runner

USER root
RUN dnf module install -y nodejs:14/default
USER $UID
```

Just like that, we have created the [Node runner image](../node/).
