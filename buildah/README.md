## Buildah/Podman Actions Runner

[![Quay org](https://img.shields.io/badge/quay-redhat--github--actions%2Fbuildah--runner-red)](https://quay.io/repository/redhat-github-actions/buildah-runner)

The Buildah/Podman Actions Runner extends the base runner to include Buildah, Podman, and the dependencies they need to run in a rootless, containerized environment.

In order for OpenShift containers to run Buildah and Podman, the user or ServiceAccount that deploys the pod must have permission to deploy using the `anyuid` SecurityContextConstraint (SCC).

If a non-administrator user is deploying the pod, an administrator must give that user permission:
`oc adm policy add-scc-to-group anyuid <user>` where user is the user who is running the buildah pod.

The pod could also be deployed by a ServiceAccount. In this case, run:
`oc adm policy add-scc-to-user anyuid -z <serviceaccount>`

Refer to [the OpenShift documentation](https://docs.openshift.com/container-platform/4.6/authentication/managing-security-context-constraints.html), and [Managing SCCs in OpenShift](https://www.openshift.com/blog/managing-sccs-in-openshift).

## Podman run
`podman run` doesn't work unless the pod is created with the `privileged` SCC.

If you need to use `podman run`, run the `oc adm policy` commands as above, but substitute `privileged` for `anyuid`.
