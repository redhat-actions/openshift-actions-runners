## Authenticating with a Runner Token

If you're not comfortable persisting a PAT with access to all of your repositories, it is possible to manually generate a runner registration token and use that.

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
