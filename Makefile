GIT_COMMIT?=$(shell git rev-parse HEAD)
GIT_COMMIT_SHORT?=$(shell git rev-parse --short HEAD)
GIT_TAG?=$(shell git describe --abbrev=0 --tags 2>/dev/null || echo "v0.0.0" )
TAG?=${GIT_TAG}-${GIT_COMMIT_SHORT}
REPO?=quay.io/costoolkit/elemental-operator-ci
REPO_REGISTER?=quay.io/costoolkit/elemental-register-ci
export ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
CHART?=$(shell find $(ROOT_DIR) -type f  -name "elemental-operator*.tgz" -print)
CHART_VERSION?=$(subst v,,$(GIT_TAG))
KUBE_VERSION?="v1.24.6"
CLUSTER_NAME?="operator-e2e"
RAWCOMMITDATE=$(shell git log -n1 --format="%at")
COMMITDATE?=$(shell date -d @"${RAWCOMMITDATE}" "+%FT%TZ")
GO_TPM_TAG?=$(shell grep google/go-tpm-tools go.mod | awk '{print $$2}')
E2E_CONF_FILE ?= $(ROOT_DIR)/tests/e2e/config/config.yaml

LDFLAGS := -w -s
LDFLAGS += -X "github.com/rancher/elemental-operator/pkg/version.Version=${GIT_TAG}"
LDFLAGS += -X "github.com/rancher/elemental-operator/pkg/version.Commit=${GIT_COMMIT}"
LDFLAGS += -X "github.com/rancher/elemental-operator/pkg/version.CommitDate=${COMMITDATE}"

.PHONY: build
build: operator register support

.PHONY: operator
operator:
	CGO_ENABLED=0 go build -ldflags '$(LDFLAGS)' -o build/elemental-operator $(ROOT_DIR)/cmd/operator


.PHONY: register
register:
	CGO_ENABLED=1 go build -ldflags '$(LDFLAGS)' -o build/elemental-register $(ROOT_DIR)/cmd/register

.PHONY: support
support:
	CGO_ENABLED=0 go build -ldflags '$(LDFLAGS)' -o build/elemental-support $(ROOT_DIR)/cmd/support


.PHONY: build-docker-operator
build-docker-operator:
	DOCKER_BUILDKIT=1 docker build \
		-f Dockerfile \
		--target elemental-operator \
		--build-arg "TAG=${GIT_TAG}" \
		--build-arg "COMMIT=${GIT_COMMIT}" \
		--build-arg "COMMITDATE=${COMMITDATE}" \
		-t ${REPO}:${TAG} .

.PHONY: build-docker-register
build-docker-register:
	DOCKER_BUILDKIT=1 docker build \
		-f Dockerfile \
		--target elemental-register \
		--build-arg "TAG=${GIT_TAG}" \
		--build-arg "COMMIT=${GIT_COMMIT}" \
		--build-arg "COMMITDATE=${COMMITDATE}" \
		-t ${REPO_REGISTER}:${TAG} .

.PHONY: build-docker-push-operator
build-docker-push-operator: build-docker-operator
	docker push ${REPO}:${TAG}

.PHONY: build-docker-push-register
build-docker-push-register: build-docker-register
	docker push ${REPO_REGISTER}:${TAG}

.PHONY: chart
chart:
	mkdir -p  $(ROOT_DIR)/build
	cp -rf $(ROOT_DIR)/chart $(ROOT_DIR)/build/chart
	sed -i -e 's/tag:.*/tag: '${TAG}'/' $(ROOT_DIR)/build/chart/values.yaml
	sed -i -e 's|repository:.*|repository: '${REPO}'|' $(ROOT_DIR)/build/chart/values.yaml
	helm package --version ${CHART_VERSION} --app-version ${GIT_TAG} -d $(ROOT_DIR)/build/ $(ROOT_DIR)/build/chart
	rm -Rf $(ROOT_DIR)/build/chart

validate:
	scripts/validate

unit-tests-deps:
	go install -mod=mod github.com/onsi/ginkgo/v2/ginkgo@latest
	go install github.com/onsi/gomega/...

.PHONY: unit-tests
unit-tests: unit-tests-deps
	ginkgo -r -v  --covermode=atomic --coverprofile=coverage.out -p -r ./pkg/...

e2e-tests: chart setup-kind
	export EXTERNAL_IP=`kubectl get nodes -o jsonpath='{.items[].status.addresses[?(@.type == "InternalIP")].address}'` && \
	export BRIDGE_IP="172.18.0.1" && \
	export CONFIG_PATH=$(E2E_CONF_FILE) && \
	cd $(ROOT_DIR)/tests && ginkgo -progress --fail-fast -r -v ./e2e

# Only setups the kind cluster
setup-kind:
	KUBE_VERSION=${KUBE_VERSION} $(ROOT_DIR)/scripts/setup-kind-cluster.sh

# setup the cluster but not run any test!
# This will build the image locally, the chart with that image,
# setup kind, load the local built image into the cluster,
# and run a test that does nothing but installs everything for
# the elemental operator (nginx, rancher, operator, etc..) as part of the BeforeSuite
# So you end up with a clean cluster in which nothing has run
setup-full-cluster: build-docker-operator chart setup-kind
	@export EXTERNAL_IP=`kubectl get nodes -o jsonpath='{.items[].status.addresses[?(@.type == "InternalIP")].address}'` && \
	export BRIDGE_IP="172.18.0.1" && \
	export CHART=$(CHART) && \
	export CONFIG_PATH=$(E2E_CONF_FILE) && \
	kind load docker-image --name $(CLUSTER_NAME) ${REPO}:${TAG} && \
	cd $(ROOT_DIR)/tests && ginkgo -r -v --label-filter="do-nothing" ./e2e

kind-e2e-tests: build-docker-operator chart setup-kind
	export CONFIG_PATH=$(E2E_CONF_FILE) && \
	kind load docker-image --name $(CLUSTER_NAME) ${REPO}:${TAG}
	$(MAKE) e2e-tests

# This builds the docker image, generates the chart, loads the image into the kind cluster and upgrades the chart to latest
# useful to test changes into the operator with a running system, without clearing the operator namespace
# thus losing any registration/inventories/os CRDs already created
reload-operator: build-docker-operator chart
	kind load docker-image --name $(CLUSTER_NAME) ${REPO}:${TAG}
	helm upgrade -n cattle-elemental-system elemental-operator $(CHART)

.PHONY: vendor
vendor:
	go mod vendor
	curl -L 'https://github.com/google/go-tpm-tools/archive/refs/tags/$(GO_TPM_TAG).tar.gz' --output go-tpm-tools.tar.gz
	tar xaf go-tpm-tools.tar.gz --strip-components=1 -C vendor/github.com/google/go-tpm-tools
	rm go-tpm-tools.tar.gz

