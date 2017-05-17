# biplane

Control your Kong instance through simple configuration.

[![Build Status](https://travis-ci.org/articulate/biplane.svg?branch=master)](https://travis-ci.org/articulate/biplane)

![biplane](http://drops.articulate.com/w1ad/NQlLBhGp+)

## Versioning :warning:

- The `1.3.x` branch and release branch is for pre-0.10 Kong, namely the `0.9.x` branch.
- The `1.4.x` release line (currently master) is for Kong `+0.10.x`.

The `1.4.x` branch is being actively developed to keep up with changes in the latest Kong release cycles. `1.3.x` will be maintained with any backwards compatable changes needed to resolve issues found in future releases that affect Kong `0.9.x`. We will likely not add new features introduced to `1.4.x` to the `1.3.x` branch.

## Installation

Download a binary from the [releases page](https://github.com/articulate/biplane/releases) and place somewhere in your `PATH`.

You will likely also need to install libevent, libyaml and [bdw-gc](http://braumeister.org/formula/bdw-gc) via Homebrew:

`brew install libevent libyaml bdw-gc`

### Docker

We also provide a [Docker image](https://hub.docker.com/r/articulate/biplane): `docker pull articulate/biplane`. Images are tagged to match versions as they are released.

- `latest` = last tagged version
- `master` = current code available on GitHub `master` branch.
- `X.Y.Z` = matches release from the GitHub [releases](https://github.com/articulate/biplane/releases) page.

## Usage

### The `--help`

```
biplane - Biplane manages your config changes to a Kong instance

Usage:
  biplane [command] [arguments]

Commands:
  apply [filename]        # Apply config to Kong instance
  config [cmd] [options]  # Set biplane configuration options
  diff [filename]         # Diff Kong instance with local config
  dump [filename]         # Retrieve current Kong config
  help [command]          # Help about any command.
  version                 # Print biplane version

Flags:
  -h, --help  # Help for this command. default: 'false'.
```

### Using Docker

As the Docker image is pointed at the biplane executable simply provide parameters to actually do something.

Get the help file.

    docker run --rm -it articulate/biplane -h

Dump the current config to STDOUT

    docker run --rm -it articulate/biplane dump --host="my-machine-name" --no-https

### Config format

Biplane follows the same conventions as [Kongfig](https://github.com/mybuilder/kongfig). If you want to start configuration from an existing Kong instance, you can dump the current config and modify as needed.

`biplane dump --host <kong ip/hostname> kong.yml`

Config can also be dumped to `stdout` if no output file is specified. The format can also be modified to output as JSON, though the JSON file **cannot** be used to configure Kong through biplane.

`biplane dump <...> --format json kong.json`

A dumped file might look like the following:

```yaml
---
apis:
  - name: products_admin_api
    attributes:
      uris: /admin/products
      strip_uri: true
      upstream_url: http://www.example.com/admin/products
    plugins:
      - name: acl
        attributes:
          config:
            whitelist:
              - google-auth
      - name: jwt
        attributes:
          config:
            key_claim_name: aud
            secret_is_base64: true
            uri_param_names:
              - jwt

consumers:
  - username: google-auth
    credentials:
      - name: jwt
        attributes:
          key: xxx
          secret: yyy
    acls:
      - group: google-auth
  - username: docs-user
    credentials:
      - name: basic-auth
        attributes:
          username: abc
          password: efg
    acls:
      - group: docs
```

You do not need to dump an API in order to apply it. It is merely a convenience mechanism to work with existing Kong instances. You can build a config file from scratch so long as it conforms to the structure shown above.

### Persistent Options

Most biplane actions require a host or IP, a port (if not the default of 8001) and, if not using SSL, the `--no-https` flag. These flags can be saved using the `config` command:

`biplane config set kong.host=api.example.com kong.port=8888 kong.https=false`

This will allow you to simply run biplane commands without needing to specify the host/port/https flags each time you run a command.

### Applying Config

`biplane apply my-config.yaml`

This will also show the differences as they are applied. If you would rather dry run this operation, use the [`diff`](#diffing) command instead.

### Diffing

`biplane diff my-config.yaml`

This will output a colored diff of changes between your local config and the current API. One caveat is that Kong often supplies _and returns_ default values that are not required to be set in the calls to the API. So the diff can often contain differences that you did not set in your config. This **will** trigger an API call when doing an `apply`, however, if they are default values and they remain unchanged in your config, this update will not affect any change. In order to avoid these "false positives", please add any default values supplied by Kong to your config. This is good practice anyways to avoid issues where Kong or plugin vendors might update defaults without your knowledge.

## Building Locally

If you have Crystal 0.15.0 installed (the currently supported version of Crystal), you can simply `make build`

If you don't or can't install 0.15.0, you can build it using the local Dockerfile definition:

`make build-container`

This will install deps, run specs and build the executable.

To run: `./bin/docker <command>`

This runtime will load files from the local directory that the command is run from.

You can also simply use the command in the `bin/docker` file to run the built image anywhere you want on your filesystem.

## Roadmap

_(In no particular order)_

- [x] Config linting
- [x] Variable interpolation in the config
- [ ] Parallel fanout of API requests
- [ ] Self updating binary
- [ ] Extract Kong library into separate shard
- [ ] Prettier error messaging

## Contributing

1. Fork it ( https://github.com/plukevdh/biplane/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [plukevdh](https://github.com/plukevdh) Luke van der Hoeven - creator, maintainer
