FROM articulate/biplane:local

# update the sources
COPY src/ /opt/biplane/src
COPY spec/ /opt/biplane/spec

WORKDIR /opt/biplane
CMD make test
