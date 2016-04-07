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
	git commit src/biplane/version.cr -m "bump version to $(VERSION)"
	git push origin master
	git tag $(VERSION)
	git push origin tag $(VERSION)
