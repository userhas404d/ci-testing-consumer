BIN_DIR ?= ${HOME}/bin
TMP ?= /tmp

PATH := $(BIN_DIR):${PATH}
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

# https://stackoverflow.com/a/18137056/12031185
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))

IMAGE_NAME := $(CURRENT_DIR):latest

docker/build: GET_IMAGE_ID := docker inspect --type=image -f '{{.Id}}' "$(IMAGE_NAME)" 2> /dev/null || true
docker/build: IMAGE_ID ?= $(shell $(GET_IMAGE_ID))
docker/build:
	@echo "[$@]: building docker image"
	[ -z $(IMAGE_ID) ] && docker build -t $(IMAGE_NAME) -f Dockerfile . || echo "Image present"
	@echo "[$@]: Docker image build complete"

# Adds the current Makefile working directory as a bind mount
docker/run: docker/build
	@echo "[$@]: Running docker image"
	docker run --rm -ti -v "$(CURDIR):/ci-harness/$(CURRENT_DIR)" $(IMAGE_NAME) $(target)

docker/clean:
	@echo "[$@]: Cleaning docker environment"
	docker image prune -a -f
	@echo "[$@]: cleanup successful"