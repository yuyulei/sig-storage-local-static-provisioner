# Copyright 2018 The Kubernetes Authors.
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

ifeq ($(REGISTRY),)
	REGISTRY = quay.io/external_storage
endif

ifeq ($(VERSION),)
	VERSION = latest
endif

ifeq ($(GOVERSION),)
	GOVERSION = 1.11.1
endif

IMAGE = $(REGISTRY)/local-volume-provisioner:$(VERSION)
MUTABLE_IMAGE = $(REGISTRY)/local-volume-provisioner:latest

all: provisioner
.PHONY: all

verify:
	./hack/verify-all.sh
.PHONY: verify

e2e:
	./hack/e2e.sh
.PHONY: e2e

release:
	./hack/release.sh
.PHONY: release

provisioner:
	docker build -t $(MUTABLE_IMAGE) --build-arg GOVERSION=${GOVERSION} -f deployment/docker/Dockerfile .
	docker tag $(MUTABLE_IMAGE) $(IMAGE)
.PHONY: provisioner

push: provisioner
	docker push $(IMAGE)
	docker push $(MUTABLE_IMAGE)
.PHONY: push

test: provisioner
	go test ./cmd/... ./pkg/...
	docker run --privileged -v $(PWD)/deployment/docker/test.sh:/test.sh --entrypoint bash quay.io/external_storage/local-volume-provisioner:latest /test.sh
.PHONY: test

clean:
	rm -f deployment/docker/local-volume-provisioner
.PHONY: clean
