VERSION:= $(shell crystal eval 'require "./src/biplane/version"; puts Biplane::VERSION')

all: setup test build-release

setup:
	crystal deps install

build:
	crystal build src/biplane.cr

build-release:
	crystal build --release src/biplane.cr

test:
	crystal spec

release: all
	git tag $(VERSION)
	git push origin tag $(VERSION)
