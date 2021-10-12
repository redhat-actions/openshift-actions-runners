## Setting up a GitHub App for Runner Registration

You can create a GitHub App for your user account, or any organization.

The following app permissions are required for each supported type of runner:

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

<!-- markdown-link-check-disable-next-line -->
- [Create GitHub Apps on your account](https://github.com/settings/apps/new?url=https://github.com/redhat-actions/openshift-actions-runners&webhook_active=false&public=false&administration=write&actions=read)

If you want to create a GitHub App for your organization, replace the `:org` part of the following URL with your organization name before opening it. Then enter any unique name in the "GitHub App name" field, and hit the "Create GitHub App" button at the bottom of the page to create a GitHub App.

<!-- markdown-link-check-disable-next-line -->
- [Create GitHub Apps on your organization](https://github.com/organizations/:org/settings/apps/new?url=https://github.com/redhat-actions/openshift-actions-runners&webhook_active=false&public=false&administration=write&organization_self_hosted_runners=write&actions=read)

You will see an *App ID* on the page of the GitHub App you created. You will need the value of this App ID later.

Download the private key file by pushing the "Generate a private key" button at the bottom of the GitHub App page. This file will also be used later.

Go to the "Install App" tab on the left side of the page and install the GitHub App that you created for your account or organization.

When the installation is complete, you will be taken to a URL in one of the following formats. The number at the end of the URL will be used as the Installation ID later.

For example, if the URL ends in `settings/installations/12345`, then the Installation ID is `12345`.

- `https://github.com/settings/installations/${INSTALLATION_ID}`
- `https://github.com/organizations/eventreactor/settings/installations/${INSTALLATION_ID}`

### Running Locally with GitHub App Authentication

You need to set the `GITHUB_APP_ID`, `GITHUB_APP_INSTALL_ID`, and `GITHUB_APP_PEM` env variables and pass them to your container.

The easiest way to get the private key in the correct form is to copy paste it into the environment variable. Newlines must be preserved.

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
