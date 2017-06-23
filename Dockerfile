FROM jhass/crystal-build-x86_64:0.15.0
MAINTAINER Luke van der Hoeven <plukevdh@articulate.com>

RUN mkdir /opt/biplane

COPY Makefile /opt/biplane/
COPY shard.* /opt/biplane/
COPY src/ /opt/biplane/src

WORKDIR /opt/biplane
RUN make setup
RUN make build
RUN mkdir /kong
WORKDIR /kong
VOLUME /kong

ENTRYPOINT ["/opt/biplane/biplane"]
