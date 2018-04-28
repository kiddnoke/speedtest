#
#  Makefile for Go
#
SHELL=/usr/bin/env bash
VERSION=$(shell git describe --tags --always)
PACKAGES = $(shell find ./ -type d | grep -v 'vendor' | grep -v '.git' | grep -v 'bin')

.PHONY: list
.PHONY: test-cover-html

default: build

build:
	go build -ldflags="-X main.Version=${VERSION}" -o bin/speedtest-${VERSION} ./cmd/speedtest

static:
	CGO_ENABLED=0 GOOS=linux go build -a -ldflags="-extldflags \"static\"" -o bin/speedtest

clean:
	scripts/clean.sh

vet:
	go vet ./cmd/...
	go vet ./internal/...

lint:
	golint ./cmd/...
	golint ./internal/...

fmt:
	gofmt -w ./cmd/speedtest
	gofmt -w ./internal/coords
	gofmt -w ./internal/misc
	gofmt -w ./internal/print
	gofmt -w ./internal/sthttp
	gofmt -w ./internal/stxml
	gofmt -w ./internal/tests

test:
	go test $(shell glide nv)

cover:
	go test -cover $(shell glide nv)

coverage:
	echo "mode: count" > coverage-all.out
	$(foreach pkg,$(PACKAGES),\
		go test -coverprofile=coverage.out -covermode=count $(pkg);\
		tail -n +2 coverage.out >> coverage-all.out;)
	go tool cover -html=coverage-all.out

cross:
	scripts/cross-compile.sh
