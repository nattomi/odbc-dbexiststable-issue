DB2_DRIVER_VERSION ?= 11.5.8
ODBC_VERSION ?= 1.5.0
IMAGE_NAME ?= odbcdb2
IMAGE_TAG := $(DB2_DRIVER_VERSION)-$(ODBC_VERSION)
FULL_IMAGE_NAME := $(IMAGE_NAME):$(IMAGE_TAG)

DOCKER := podman

.PHONY: build
build: clidriver
	$(DOCKER) build \
          --build-arg ODBC_VERSION=$(ODBC_VERSION) \
          -t $(FULL_IMAGE_NAME) .

linuxx64_odbc_cli.tar.gz:
	curl -L -o linuxx64_odbc_cli.tar.gz https://github.com/ibmdb/db2drivers/raw/d4ed4d6/clidriver/v$(DB2_DRIVER_VERSION)/linuxx64_odbc_cli.tar.gz

.PHONY: clidriver
clidriver: clidriver/bin/db2cli

clidriver/bin/db2cli: linuxx64_odbc_cli.tar.gz
	tar --touch -xzvf linuxx64_odbc_cli.tar.gz

.PHONY: clean
clean:
	rm -rf linuxx64_odbc_cli.tar.gz
	rm -rf clidriver
