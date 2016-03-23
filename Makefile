DOCKER_LOCAL_IP:= $(shell docker-machine ip default)
VERSION:= $(shell crystal eval 'require "./src/biplane/version"; puts Biplane::VERSION')

all: test build-release

build:
	crystal build src/biplane.cr

build-release:
	crystal build --release src/biplane.cr

test:
	crystal spec

release: all
	git tag $(VERSION)
	git push origin tag $(VERSION)

dump-local: build
	./biplane dump --host $(DOCKER_LOCAL_IP) --no-https testing.yml

diff-local: build
	./biplane diff --host $(DOCKER_LOCAL_IP) --no-https testing.yml
