# dnsimple-terraform-ip-fixer

## Usage

This container consumes the following environment variables:

| Name               | Description                                                                        |
|--------------------|------------------------------------------------------------------------------------|
| `TFC_TOKEN`        | A user token from the Terraform Cloud account                                      |
| `TFC_WORKSPACE_ID` | The ID of the workspace in the Terraform Cloud organization in which the IP is set |

## Building

This Docker image is built for ARM 32 v7 architecture.
To build the image on a machine of a different architecture, we need to use the experimental `buildx` feature:

```bash
# from the root of this repository:

docker buildx build --platform linux/arm/v7 -t docker-registry.tlake.io/tlake/dnsimple-terraform-ip-fixer . --push
```

Make sure that we've done `docker login docker-registry.tlake.io`.

### Enabling Multi-Arch Builds

* https://stackoverflow.com/questions/63380739/exec-format-error-when-building-docker-image-from-arm32v7-golang-image
* https://gitlab.alpinelinux.org/alpine/docker-abuild#configure-multi-arch-support
* https://admantium.medium.com/docker-building-images-for-multiple-architectures-4f142f6dda71

In the event that these resources go away, here's an attempt to copy down the relevant info:

> You need to enable execution of different multi-architecture containers by QEMU and binfmt_misc.
> 
> In recent distro this can be simply done by running:
> 
> ```apt-get install qemu-user-static```
>
> If this doesn't work for you, you can execute :
> 
> ```docker run --rm --privileged multiarch/qemu-user-static --reset --persistent yes --credential yes```
>
> Note that this may reconfigure any existing binfmt_misc setup that you have. See https://github.com/multiarch/qemu-user-static for more detail.

