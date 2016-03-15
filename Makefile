DOCKER_LOCAL_IP:= $(shell docker-machine ip default)

build:
	crystal build src/biplane.cr

test:
	crystal spec

dump-local: build
	./biplane dump --host $(DOCKER_LOCAL_IP) --no-https testing.yml

diff-local: build
	./biplane diff --host $(DOCKER_LOCAL_IP) --no-https testing.yml
