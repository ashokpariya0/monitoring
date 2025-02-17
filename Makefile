# Default to podman
CONTAINER_RUNTIME ?= podman

.PHONY: metricsdocs
metricsdocs: build-metricsdocs
	@[ "${CONFIG_FILE}" ] || ( echo "CONFIG_FILE is not set"; exit 1 )

	tools/metricsdocs/_out/metricsdocs \
		--config-file $(CONFIG_FILE)

.PHONY: build-metricsdocs
build-metricsdocs:
	cd ./tools/metricsdocs && go build -ldflags="-s -w" -o _out/metricsdocs .

.PHONY: promlinter-build
promlinter-build:
	${CONTAINER_RUNTIME} build -t ${IMG} test/metrics/prom-metrics-linter

.PHONY: promlinter-push
promlinter-push:
	${CONTAINER_RUNTIME} push ${IMG}

.PHONY: monitoringlinter-unit-test
monitoringlinter-unit-test:
	go test ./monitoringlinter/...

.PHONY: monitoringlinter-build
monitoringlinter-build:
	go build -o bin/ ./monitoringlinter/cmd/monitoringlinter

.PHONY: monitoringlinter-test
monitoringlinter-test: monitoringlinter-build
	./monitoringlinter/tests/e2e.sh

.PHONY: lint-markdown
lint-markdown:
	echo "Linting markdown files"
	podman run -v ${PWD}:/workdir:Z docker.io/davidanson/markdownlint-cli2:v0.13.0 "/workdir/docs/*runbooks/*.md"

.PHONY: build-runbook-sync-downstream
build-runbook-sync-downstream:
	cd tools/runbook-sync-downstream && go build -ldflags="-s -w" -o _out/runbook-sync-downstream .

.PHONY: runbook-sync-downstream
runbook-sync-downstream: build-runbook-sync-downstream
	tools/runbook-sync-downstream/_out/runbook-sync-downstream
