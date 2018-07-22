#!/bin/bash

# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Add GCP credentials path to configuration defaults file.

# Check arguments for existing json key file.
# arguments: <project-id>-<unique-id>.json
function checkArgs () {
  local FILE_ARG='<path to json service account key file>'

  if [ -z "$1" ]; then
    echo 'Error: missing argument.'
    echo "$0 ${FILE_ARG}"
    exit 1
  fi

  if [ "$1" != "exists" ] && [ ! -e "$1" ]; then
    echo 'Error: file not found.'
    echo "$0 ${FILE_ARG}"
    exit 1
  fi
}


# Backup existing credentials and create new ones.
# arguments: source_credentials_file target_file_path
function backupAndCopyCredentials() {
  local BACKUP_FILE="$2.bak.$(date +%s)"
  if [ -e $2 ]; then
    cp "$2" "${BACKUP_FILE}"
    echo "Created backup (${BACKUP_FILE})."
  fi

  cp "$1" "$2"
  echo "Created $2 from $1."
}


# Start a new terraform.tfvars file.
# arguments: full_path_file_name.
function createTFVars() {
  if [ ! -e $1 ]; then
    echo "/*" > $1
    echo " * Initialized Terraform variables." >> $1
    echo " */" >> $1
  fi
}


# If not already present, add a key-value to tfvars file.
# arguments: tfvars_path_file_name key value
function addTFVar() {
  if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo 'Error: missing argument for addTFVar().'
    exit 1
  fi

  local VAR_NAME="$2"
  local KEY_EXISTS="$(cat $1 | grep $2)"

  if [ -z "${KEY_EXISTS}" ]; then
    echo "" >> $1
    echo "$2 = \"$3\"" >> $1
    echo "Updated $2 in $1."
  fi
}


# Create fresh GCP credentials file and point Terraform at it.
# arguments: <project-id>-<unique-id>.json
function createCredentials () {
  # ~ only expands when NOT quoted (below).
  local CREDS_FILE_DIR=~/.config/gcloud
  local CREDS_FILE_PATH="${CREDS_FILE_DIR}/credentials_autonetdeploy.json"
  local THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  local TFVARS_DIR_PATH="${THIS_DIR}/terraform"
  local TFVARS_FILE_PATH="${TFVARS_DIR_PATH}/terraform.tfvars"
  local TFVAR_CREDS='gcp_credentials_file_path'

  if [ "$1" != "exists" ]; then
    mkdir -p ${CREDS_FILE_DIR}
    backupAndCopyCredentials $1 ${CREDS_FILE_PATH}
  fi

  createTFVars "${TFVARS_FILE_PATH}"
  addTFVar "${TFVARS_FILE_PATH}" "${TFVAR_CREDS}" "${CREDS_FILE_PATH}"
}


# Copy/create file under ~/.config/gcloud
checkArgs $1
# Pass "exists" to skip credential file copying.
createCredentials $1
