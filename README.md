# BOINC client container image

Custom image for the BOINC client based upon the [official way of working][github].

<details style="margin-bottom: 1em">
<summary>Base image</summary>

```sh
docker buildx build --load \
  -f 'Dockerfile.base-leap' \
  -t "docker.io/michelecereda/boinc-client:base-leap-7.22.0-$(date +%+4Y%m%d)" \
  '.'

docker run --rm --name 'boinc-client' \
  --net='host' \
  --pid='host' \
  --cap-add 'SYS_NICE' \
  -v "${PWD}/data:/var/lib/boinc" \
  -e BOINC_GUI_RPC_PASSWORD="123" \
  -e BOINC_CMD_LINE_OPTIONS="--allow_remote_gui_rpc" \
  'docker.io/michelecereda/boinc-client:base-leap-7.22.0-20240212'
```

</details>

Non-base images rely on the base image.<br/>
Make sure it is accessible from the builder during builds. One might need to use the 'default' builder (or any other using the `docker` driver).

<details>
<summary>AMD GPU-savvy image</summary>

```sh
docker buildx build --load \
  -f 'Dockerfile.amd-leap' \
  -t "docker.io/michelecereda/boinc-client:amd-leap-7.22.0-$(date +%+4Y%m%d)" \
  '.'

docker run --rm --name 'boinc-client' \
  --net='host' \
  --pid='host' \
  --cap-add 'SYS_NICE' \
  --device '/dev/dri:/dev/dri' \
  --device '/dev/kfd:/dev/kfd' \
  --group-add 'video' \
  -v "${PWD}/data:/var/lib/boinc" \
  -e BOINC_GUI_RPC_PASSWORD="123" \
  -e BOINC_CMD_LINE_OPTIONS="--allow_remote_gui_rpc" \
  'docker.io/michelecereda/boinc-client:amd-leap-7.22.0-20240212'
```

</details>
<details>
<summary>Intel GPU-savvy image</summary>

```sh
docker buildx build --load \
  -f 'Dockerfile.intel-leap' \
  -t "docker.io/michelecereda/boinc-client:intel-leap-7.22.0-$(date +%+4Y%m%d)" \
  '.'

docker run --rm --name 'boinc-client' \
  --net='host' \
  --pid='host' \
  --cap-add 'SYS_NICE' \
  --device '/dev/dri:/dev/dri' \
  -v "${PWD}/data:/var/lib/boinc" \
  -e BOINC_GUI_RPC_PASSWORD="123" \
  -e BOINC_CMD_LINE_OPTIONS="--allow_remote_gui_rpc" \
  'docker.io/michelecereda/boinc-client:intel-leap-7.22.0-20240212'
```

</details>

## Gotchas

- Executing the client as the `boinc` user and group requires any files in the `/var/lib/boinc` directory to be:

  - owned by the `boinc` user (uid `499`), and/or
  - readable **and** writable by the `boinc` user (uid `499`) and/or `boinc` group (gid `486`), and/or
  - globally readable, possibly writable.

  When mounting the directory locally (like in the examples above and compose files), make sure they have the correct permissions.

- `pid: host` is used to let the containerized BOINC client determine non-BOINC processes for CPU percentages and exclusive applications.

## Sources

- [Github]
- [Docker hub]

<!--
  References
  -->

<!-- Upstream -->
[docker hub]: https://hub.docker.com/r/boinc/client
[github]: https://github.com/BOINC/boinc-client-docker
