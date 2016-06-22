FROM jhass/crystal-build-x86_64:0.15.0

RUN mkdir /biplane

COPY Makefile /biplane/
COPY shard.* /biplane/
COPY src/ /biplane/src
COPY spec/ /biplane/spec

WORKDIR /biplane
RUN make setup
RUN make test
RUN make build

ENTRYPOINT ["./biplane"]
