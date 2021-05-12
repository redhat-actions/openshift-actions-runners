# Kubernetes Tools Runner

[![Quay org](https://img.shields.io/badge/quay-redhat--github--actions%2Fk8s--tools--runner-red)](https://quay.io/repository/redhat-github-actions/k8s-tools-runner)


The Kubernetes tools runner is the [base runner](../base) plus a set of CLIs used to work with OpenShift/Kubernetes clusters.

The version of each tool to install can be edited using a Docker `--build-arg`. View the [Containerfile](./Containerfile) to see the build args to use.

Since most tools are installed from the [OpenShift V4 mirror](https://mirror.openshift.com/pub/openshift-v4/clients/), make sure the desired version is available there first. Refer to the [install-tools](./install-tools.sh) script to see where each CLI is fetched from.

Note that `kubectl` is packaged together with `oc`.

| Tool | Version |
| ---- | ------- |
| helm | 3.5.0 |
| kn | 0.19.1 |
| oc | 4.6.18 |
| tkn | 0.15.0 |
| yq | 4.6.0 |
