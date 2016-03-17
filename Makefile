DOCKER_LOCAL_IP:= $(shell docker-machine ip default)
VERSION:= $(shell crystal eval 'require "./src/biplane/version"; puts Biplane::VERSION')

build:
	crystal build src/biplane.cr

build-release:
	crystal build --release src/biplane.cr

test:
	crystal spec

release: build
	git tag $(VERSION)
	git push origin tag $(VERSION)

dump-local: build
	./biplane dump --host $(DOCKER_LOCAL_IP) --no-https testing.yml

diff-local: build
	./biplane diff --host $(DOCKER_LOCAL_IP) --no-https testing.yml
