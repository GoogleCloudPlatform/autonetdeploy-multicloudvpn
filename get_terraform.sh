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


# Download Terraform utility.

# Download and extract Terraform utility in the terraform directory.
function getTerraform() {
  # Places terraform in ~/terraform dir.
  local T_VERSION='0.12.4/terraform_0.12.4_linux_amd64'
  local T_URL="https://releases.hashicorp.com/terraform/${T_VERSION}.zip"
  # ~ only expands when NOT quoted (below).
  local T_DIR=~/terraform
  local T_ZIP="${T_DIR}/terraform.zip"
  local T_EXE="${T_DIR}/terraform"

  if [ -e ${T_EXE} ]; then
    echo "${T_EXE} already exists. Exiting."
    echo ''
    echo "To adjust your path: export PATH=${T_DIR}:\${PATH}"
    exit 0
  fi

  mkdir -p ${T_DIR}
  pushd ${T_DIR} > /dev/null
  curl -o "${T_ZIP}" "${T_URL}"
  unzip -q "${T_ZIP}"
  rm "${T_ZIP}"
  popd > /dev/null

  if [ -e ${T_EXE} ]; then
    echo "Successfully retrieved ${T_EXE}."
    echo ''
    echo "To adjust your path: export PATH=${T_DIR}:\${PATH}"
  else
    echo "Could not retrieve ${T_EXE}."
  fi
}

getTerraform
