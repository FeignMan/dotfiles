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

rbw_export_folder() {
  if [[ "$#" -lt 1 ]]; then
    echo "You must specify a folder as the argument" >&2
    return
  fi

  local folder=$1
  echo "🔍 Exporting secrets from folder: $folder"

  local existing_agents=$(pgrep -f "rbw-agent" 2>/dev/null || true)
  while read -r folder name id; do
    export "$name=$(rbw get "$id")"
    echo "✅️ Exported $name"
  done < <(rbw list --fields folder --fields name --fields id 2>/dev/null | grep "^${folder}")

  # Kill only the NEW rbw-agent for this profile
  local current_agents=$(pgrep -f "rbw-agent" 2>/dev/null || true)
  for pid in $current_agents; do
    if [[ ! "$existing_agents" =~ $pid ]]; then
      kill "$pid" 2>/dev/null || true
      echo "🔒 Locked the vault again (rbw-agent $pid stopped)"
    fi
  done
}

rbw_export_secret() {
  if [[ "$#" -lt 2 ]]; then
    echo "You must specify a folder and a secret name as the arguments" >&2
    return
  fi

  local folder=$1
  local secret_name=$2

  echo "🔍 Exporting secret '$secret_name' from folder: $folder"

  local existing_agents=$(pgrep -f "rbw-agent" 2>/dev/null || true)

  export "$secret_name=$(rbw get --folder ${folder} ${secret_name})"
  echo "✅️ Exported $secret_name"

  # Kill only the NEW rbw-agent for this profile
  local current_agents=$(pgrep -f "rbw-agent" 2>/dev/null || true)
  for pid in $current_agents; do
    if [[ ! "$existing_agents" =~ $pid ]]; then
      kill "$pid" 2>/dev/null || true
      echo "🔒 Locked the vault again (rbw-agent $pid stopped)"
    fi
  done
}