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

FROM alpine/helm:3.6.3

LABEL maintainer="Nicolas Lamirault <nicolas.lamirault@gmail.com>" \
    org.opencontainers.image.title="helm-kubeconform-action" \
    org.opencontainers.image.description="Helm Kubeconform Github Action" \
    org.opencontainers.image.url="https://github.com/nlamirault/helm-kubeconform-action" \
    org.opencontainers.image.source="git@github.com:nlamirault/helm-kubeconform-action.git" \
    org.opencontainers.image.vendor="Github Action" \
    org.opencontainers.image.version="v0.1.0"
    
ENTRYPOINT ["/entrypoint.sh"]

RUN wget https://github.com/yannh/kubeconform/releases/download/v0.4.10/kubeconform-linux-amd64.tar.gz \
    && mkdir /kubeconform \
    && tar xf kubeconform-linux-amd64.tar.gz -C /kubeconform \
    && rm -r kubeconform-linux-amd64.tar.gz

RUN wget https://raw.githubusercontent.com/yannh/kubeconform/v0.4.8/scripts/openapi2jsonschema.py \
    && mv openapi2jsonschema.py /usr/local/bin/openapi2jsonschema.py \
    && chmod +x /usr/local/bin/openapi2jsonschema.py

COPY entrypoint.sh /entrypoint.sh