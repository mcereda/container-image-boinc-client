#!/bin/bash

# Original file:
# https://github.com/BOINC/boinc-client-docker/blob/master/bin/start-boinc.sh

# Configure the GUI RPC.
echo "$BOINC_GUI_RPC_PASSWORD" > '/var/lib/boinc/gui_rpc_auth.cfg'
echo "$BOINC_REMOTE_HOST" > '/var/lib/boinc/remote_hosts.cfg'

# Run BOINC. Full path needed for GPU support.
exec '/usr/bin/boinc' $BOINC_CMD_LINE_OPTIONS
