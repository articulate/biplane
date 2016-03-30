# biplane

Control your Kong instance through simple configuration.

[![Build Status](https://travis-ci.org/articulate/biplane.svg?branch=master)](https://travis-ci.org/articulate/biplane)

![biplane](http://drops.articulate.com/w1ad/NQlLBhGp+)

## Installation

Download a binary from the [releases page](https://github.com/articulate/biplane/releases) and place somewhere in your `PATH`.

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

### Config format

Biplane follows the same conventions as [Kongfig](https://github.com/mybuilder/kongfig). If you want to start configuration from an existing Kong instance, you can dump the current config and modify as needed.

`biplane dump --host <kong ip/hostname> kong.yml`

Config can also be dumped to `stdout` if no output file is specified. The format can also be modified to output as JSON, though the JSON file **cannot** be used to configure Kong through biplane.

`biplane dump <...> --format json kong.json`

A dumped file might look like the following:

```ymal
---
apis:
  - name: products_admin_api
    attributes:
      request_path: /admin/products
      strip_request_path: true
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

## Roadmap

_(In no particular order)_

- [ ] Config linting
- [ ] Variable interpolation in the config
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
