VERSION:= $(shell crystal eval 'require "./src/biplane/version"; puts Biplane::VERSION')
CWD:=$(shell pwd)

all: setup test build-release

setup:
	crystal deps install

build:
	crystal build src/cli.cr -o biplane

build-release:
	crystal build --release src/cli.cr -o biplane

test:
	crystal spec

release: all
	git push origin master
	git tag $(VERSION)
	git push origin tag $(VERSION)

build-head:
	docker build -t articulate/biplane:crystal-head .
	docker run --rm articulate/biplane:crystal-head crystal -v
	docker run -v $(CWD):/biplane articulate/biplane:crystal-head make build
