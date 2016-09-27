VERSION:= $(shell crystal eval 'require "./src/biplane/version"; puts Biplane::VERSION')

all: setup test build-release

setup:
	crystal deps install

build:
	crystal build src/cli.cr -o biplane

build-container:
	docker build -t articulate/biplane:local .

test-container:
	docker build -t articulate/biplane:test -f test.Dockerfile .
	docker run --entrypoint=crystal --rm articulate/biplane:test spec spec/models/* spec/configs/*

build-release:
	crystal build --release src/cli.cr -o biplane

test:
	crystal spec

release: all
	git push origin master
	git tag $(VERSION)
	git push origin tag $(VERSION)
