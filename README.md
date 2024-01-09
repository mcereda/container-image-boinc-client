# BOINC client container image

Custom image for the BOINC client based upon the official way of working.

```sh
docker build \
  -f 'Dockerfile.intel-opensuse' \
  -t 'docker.io/michelecereda/boinc-client:intel-opensuse-7.24.1' \
  '.'

docker run --rm --name 'boinc-client' \
  --net='host' \
  --pid='host' \
  --device '/dev/dri:/dev/dri' \
  -e BOINC_GUI_RPC_PASSWORD="123" \
  -e BOINC_CMD_LINE_OPTIONS="--allow_remote_gui_rpc" \
  'docker.io/michelecereda/boinc-client:intel-opensuse-7.24.1'
```
