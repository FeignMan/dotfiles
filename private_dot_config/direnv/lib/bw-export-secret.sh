#!/bin/bash

# Source logger module
source "${XDG_DATA_HOME}/scripts/logging.sh" # logger is in same directory

function bitwarden_password_to_env() {
  if [[ "$#" -lt 2 ]]; then
    log_critical "You must specify at least one folder and one secret name" >&2
    exit 1
  fi

  local BW_SESSION=$(bw unlock --raw)

  if [[ -z $BW_SESSION ]]; then
    log_critical "Failed to log into bitwarden. Ensure you're logged in with bw login, and check your password"
    exit 1
  fi

  local folder=$1
  shift

  log_info "Looking up in $folder"

  # Retrieve the folder id
  local FOLDER_ID=$(bw list folders --search "$folder" --session "$BW_SESSION" | jq -r '.[0].id')

  if [[ -z "$FOLDER_ID" || "$FOLDER_ID" = "null" ]]; then
    log_error "Failed to find the folder $folder. Please check if it exists and sync if needed with 'bw sync'"
    exit 1
  fi

  for environment_variable_name in "$@"; do
    local CREDENTIAL=$(bw list items --folderid $FOLDER_ID --search $environment_variable_name --session "$BW_SESSION" | jq -r '.[0].login.password')
    if [[ -z $CREDENTIAL || $CREDENTIAL = "null" ]]; then
      log_error "❌️ Failed to retrieve credential for $environment_variable_name in $folder, exiting with error" >&2
      exit 1
    fi

    export "$environment_variable_name"="$CREDENTIAL"
    log_message "✅️ Exported $environment_variable_name"
  done

  bw lock
}