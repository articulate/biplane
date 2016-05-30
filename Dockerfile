FROM crystallang/crystal:head

RUN apt-get update && apt-get install -y \
    build-essential \
    libyaml-dev

RUN mkdir /biplane
COPY . /biplane

WORKDIR /biplane

CMD make build
