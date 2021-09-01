# Copyright (C) 2021 Nicolas Lamirault <nicolas.lamirault@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/sh -l

# Exit on error.
set -o nounset -o errexit -o pipefail

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

reset_color="\\e[0m"
color_red="\\e[31m"
color_green="\\e[32m"
color_blue="\\e[36m";

function echo_fail { echo -e "${color_red}✖ $*${reset_color}"; }
function echo_success { echo -e "${color_green}✔ $*${reset_color}"; }
function echo_info { echo -e "${color_blue}$*${reset_color}"; }

function openapi_prometheus_operator {
  pushd /tmp/
  echo_info "Generate Prometheus Operator OpenAPI schemas"
  rm -fr kube-prometheus
  git clone https://github.com/prometheus-operator/kube-prometheus
  cd kube-prometheus
  jb install
  ./scripts/generate-schemas.sh
  popd
}

function openapi_kyverno {
  pushd /tmp/
  echo_info "Generate Kyverno OpenAPI schemas"
  rm -fr kyverno
  git clone https://github.com/kyverno/kyverno.git
  cd kyverno
  export FILENAME_FORMAT='{kind}-{group}-{version}'
  /tmp/openapi2jsonschema.py definitions/crds/*.yaml
  popd
}

function helm_chart {
    values=$1
    
    args=""
    if [ ! -z "${values}" ]; then
        args="--values ${values}"
    fi
    echo_info "Build chart ${chart} and check Kubernetes manifests"
    helm template . ${args} | \
        kubeconform -strict -verbose -summary \
        -schema-location default \
        -schema-location default \
        -schema-location="/tmp/flux-crd-schemas/master-standalone-strict/{{ .ResourceKind }}{{ .KindSuffix }}.json" \
        -schema-location="/tmp/kube-prometheus/crdschemas/{{ .ResourceKind }}.json" \
        -schema-location="/tmp/kyverno/{{ .ResourceKind }}{{ .KindSuffix }}.json" \
        && echo_success "Kubeconform succeeded!" || echo_fail "Kubeconform failed!!"
}

function validate {
    chart=$1
    echo_info "Validating Chart '${chart}'"

    pushd ${chart}
    if [ -d "ci" ]; then
        for values in ci/*-values.yaml; do
            echo_info "Use ${values}"
            helm_chart "${values}"
        done
    else
        helm_chart ""
    fi
    popd
}


[ -z "${CHARTS_PATH}" ] && echo_fail "Helm charts path not satisfied" && exit 1

openapi_prometheus_operator
openapi_kyverno

for chart in "${CHARTS_PATH}"/*/; do
    echo_info "Helm Chart: ${chart}";
    validate ${chart}    
done