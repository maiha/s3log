SHELL=/bin/bash
CRYSTAL ?= crystal
BINARY=bin/s3log
BUILD_FLAGS = --release

STATIC_LINK_FLAGS  = --link-flags "-static"
OK="\033[1;32mOK\033[0m\n"

.PHONY : all
all: build static

.PHONY : build
build:
	shards build

.PHONY : static
static: src/main/s3log.cr
	rm -f ${BINARY}
	$(CRYSTAL) build ${BUILD_FLAGS} $^ -o ${BINARY} ${STATIC_LINK_FLAGS}
	LC_ALL=C file ${BINARY} > /dev/null
	@printf $(OK)

.PHONY : github_release
github_release:
	@github-release
	@./bin/github_release
