## Buildah/Podman Actions Runner

[![Quay org](https://img.shields.io/badge/quay-redhat--github--actions%2Fbuildah--runner-red)](https://quay.io/repository/redhat-github-actions/buildah-runner)

The Buildah/Podman Actions Runner extends the [base runner](../base) to include Buildah, Podman, and the dependencies they need to run in a rootless, containerized environment.

In order for OpenShift containers to run Buildah and Podman, the user or ServiceAccount that deploys the pod must have permission to deploy using the `anyuid` SecurityContextConstraint (SCC).

Buildah has a [very good tutorial](https://github.com/containers/buildah/blob/main/docs/tutorials/05-openshift-rootless-build.md) detailing how to run buildah in OpenShift.

You can also refer to the OpenShift documentation [Managing Security Context Constraints](https://docs.openshift.com/container-platform/4.6/authentication/managing-security-context-constraints.html), and [this blog post](https://www.openshift.com/blog/managing-sccs-in-openshift).

## Deploying the buildah pod

It is recommended to deploy the pod using a ServiceAccount specifically configured to have the required permissions. An administrator must run:

```bash
# Create the ServiceAccount (if needed)
$ oc create -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: buildah-sa
EOF

serviceaccount/buildah-sa created

# Give the ServiceAccount permission to deploy with the anyuid scc.
$ oc adm policy add-scc-to-user anyuid -z buildah-sa
```

Then, when using [the Helm chart](https://github.com/redhat-actions/openshift-actions-runner-chart) to install buildah runners, you can pass `--set serviceAccountName=buildah-sa`

Or, an adminstrator can give a specific user permission:
```
oc adm policy add-scc-to-user anyuid <user>
```

## Podman run
`podman run` doesn't work unless the pod is created with the `privileged` SCC.

If you need to use `podman run`, run the `oc adm policy` commands as above, but substitute `privileged` for `anyuid`.
