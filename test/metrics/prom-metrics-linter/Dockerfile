FROM --platform=${BUILDPLATFORM} golang:1.20 AS build
ARG TARGETOS
ARG TARGETARCH

WORKDIR /workspace

COPY . .

RUN go mod tidy && \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -trimpath -ldflags "-s -w" -o /bin/ .

FROM --platform=linux/${TARGETARCH} gcr.io/distroless/base:latest

COPY --from=build /bin/prom-metrics-linter .

ENTRYPOINT ["/prom-metrics-linter"]
