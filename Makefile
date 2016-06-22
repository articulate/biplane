VERSION:= $(shell crystal eval 'require "./src/biplane/version"; puts Biplane::VERSION')

all: setup test build-release

setup:
	crystal deps install

build:
	crystal build src/cli.cr -o biplane

build-container:
	docker build -t articulate/biplane:local .

build-release:
	crystal build --release src/cli.cr -o biplane

test:
	crystal spec

release: all
	git push origin master
	git tag $(VERSION)
	git push origin tag $(VERSION)
