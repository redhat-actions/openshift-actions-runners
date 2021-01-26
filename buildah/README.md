
## buildah

Buildah has to run with permission to deploy using the 'anyuid' scc.

An admin must run:
`oc adm policy add-scc-to-group anyuid <user>` where user is the user who is running the buildah pod. or, user can be `system:authenticated`.

## podman
`podman run` doesn't work unless "privileged" mode is enabled. Other podman commands work with `anyuid`, same as buildah.

```
sh-5.0$ podman run hello-world
Resolved short name "hello-world" to a recorded short-name alias (origin: /etc/containers/registries.conf.d/shortnames.conf)
Trying to pull docker.io/library/hello-world:latest...
Getting image source signatures
Copying blob 0e03bdcc26d7 done
Copying config bf756fb1ae done
Writing manifest to image destination
Storing signatures
ERRO[0002] Error preparing container a436568b16c331fb706bf3e3a0ed98376dc30c94c51c78089f5e7f97061d9442: /usr/bin/slirp4netns failed: "open(\"/dev/net/tun\"): No such file or directory\nWARNING: Support for seccomp is experimental\nchild failed(1)\nWARNING: Support for seccomp is experimental\n"
Error: failed to mount shm tmpfs "/home/runner/.local/share/containers/storage/vfs-containers/a436568b16c331fb706bf3e3a0ed98376dc30c94c51c78089f5e7f97061d9442/userdata/shm": permission denied
```
