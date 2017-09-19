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


# Run Terraform graph command with some color-formatting and emit a png.
# terraform graph -type plan | dot -Tpng > graph.png
#
# Useful graphviz links:
# graphviz docs: http://www.graphviz.org/doc/info/attrs.html
# graphviz colors: http://www.graphviz.org/doc/info/colors.html
# webgraphviz viewer: http://www.webgraphviz.com


function runGraph() {
  local THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  local T_CMD="terraform graph -type plan"
  local D_CMD='dot -Tpng'
  local SED_EX1='s/\[root\] //g'
  local SED_EX2='/.*aws.*shape = "box"/ s/shape = "box"/shape = "box", style = "filled", fillcolor = "coral"/'
  local SED_EX3='/.*google.*shape = "box"/ s/shape = "box"/shape = "box", style = "filled", fillcolor = "deepskyblue"/'
  local SED_EX4='s/shape = "diamond"/shape = "diamond", style = "filled", fillcolor = "aquamarine"/'
  local OUT_FILE="${THIS_DIR}/gcpawsvpn_plan_graph.png"

  if [ -e ${OUT_FILE} ]; then
    echo "${OUT_FILE} already exists. Exiting."
    exit 1
  fi

  ${T_CMD} | sed -e "${SED_EX1}" -e "${SED_EX2}" -e "${SED_EX3}" \
             -e "${SED_EX4}" | ${D_CMD} > ${OUT_FILE}
  echo "Wrote ${OUT_FILE}."
}

runGraph
