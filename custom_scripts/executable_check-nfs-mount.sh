#!/bin/bash

VMID=$1       # First argument is the container ID
HOOK_STAGE=$2 # Second argument is the hook stage (e.g., pre-start, post-start, pre-stop, post-stop)

MOUNT_POINT="/mnt/truenas"
TIMEOUT=600 # Max wait time in seconds (10 minutes)
INTERVAL=5 # Check every 10 seconds

# Only run the check during the 'pre-start' stage
if [ "$HOOK_STAGE" = "pre-start" ]; then
    echo "$(date): [VMID ${VMID}] NFS Mount Check (pre-start hook): Waiting for ${MOUNT_POINT} to be available..."

    for (( i=0; i<$TIMEOUT/$INTERVAL; i++ )); do
        if mountpoint -q "$MOUNT_POINT"; then
            # Check if it's not just an empty mountpoint (e.g. nfs is available)
            if find "$MOUNT_POINT" -maxdepth 0 -empty -exec false {} +; then
                echo "$(date): [VMID ${VMID}] NFS Mount Check: ${MOUNT_POINT} is mounted and not empty."
                exit 0 # Success
            else
                echo "$(date): [VMID ${VMID}] NFS Mount Check: ${MOUNT_POINT} is mounted but appears empty. Retrying..."echo "$(date): [VMID ${VMID}] NFS Mount Check: ${MOUNT_POINT} is mounted but appears empty. Retrying..."
            fi
        fi
        echo "$(date): [VMID ${VMID}] NFS Mount Check: ${MOUNT_POINT} not yet mounted or empty. Waiting ${INTERVAL} seconds..."
        sleep $INTERVAL
    done

    echo "$(date): [VMID ${VMID}] NFS Mount Check: Timeout reached. ${MOUNT_POINT} not available. LXC will not start."
    exit 1 # Failure
else
    # For other hook stages, just exit successfully to not block them
    echo "$(date): [VMID ${VMID}] Hook script called for stage: ${HOOK_STAGE}. Exiting without action."
    exit 0
fi
