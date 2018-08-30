# INWX Update

Automate setting of DNS entries in [inwx.de](https://www.inwx.de) nameserver.

The script will:

* Query for existing records with the same name
* Delete them
* Create a new record with the specified name and value

## Usage:

### Standalone

You'll need to have a clone of this repository and a working ruby installation.

```shell
$ cd ~/Code/github.com/klausmeyer/inwx-update
$ bundle install
$ cp .env.example .env
$ $EDITOR .env # change the configs to your needs
$ bundle exec ruby script.rb
```

### Docker

Simply use the ready-to-go docker image or build on your own.

```shell
$ docker build -t klausmeyer/inwx-update . # optional to build from source
$ docker run -it --rm \
  -e LOGIN=username \
  -e PASSWORD=password \
  -e DOMAIN=example.com \
  -e TYPE=TXT \
  -e RECORD=_acme-challenge \
  -e VALUE=changeme \
  klausmeyer/inwx-update
```

### License

[MIT](LICENSE)
