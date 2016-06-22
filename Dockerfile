FROM jhass/crystal-build-x86_64:0.15.0

RUN mkdir /opt/biplane

COPY Makefile /opt/biplane/
COPY shard.* /opt/biplane/
COPY src/ /opt/biplane/src
COPY spec/ /opt/biplane/spec

WORKDIR /opt/biplane
RUN make setup
RUN make test
RUN make build

RUN mkdir /biplane
WORKDIR /biplane
VOLUME /biplane

ENTRYPOINT ["/opt/biplane/biplane"]
