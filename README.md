# bitcoind
[![AGPL License](https://img.shields.io/badge/license-AGPL-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.html)
[![CI](https://github.com/comminutus/bitcoind/actions/workflows/ci.yaml/badge.svg)](https://github.com/comminutus/bitcoind/actions/workflows/ci.yaml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/comminutus/bitcoind)](https://github.com/comminutus/bitcoind/releases/latest)


## Description
This is a container image which runs `bitcoind` from [Bitcoin Core](https://github.com/bitcoin/bitcoin) `bitcoind`.  The container image runs `bitcoind`.

Since the distributed `bitcoind` binary uses dynamically-linked glibc, it uses the [Chainguard glibc-dynamic](https://images.chainguard.dev/directory/image/glibc-dynamic/versions) base image.  This is a distroless container, and as such has very little attack surfaces.  It also has no shell, so it's not possible to execute a shell into the container.


## Getting Started
```
podman pull ghcr.io/comminutus/bitcoind
podman run -it --rm ghcr.io/comminutus/bitcoind
```

## Usage
Note that the container image does not set any other command line options other than `-datadir=/var/lib/bitcoin` (see "Volumes" below).

Because `bitcoind` supports so many options, it's best to configure it using a configuration file (typically _bitcoin.conf_). The `bitcoind` command line options can be used to point to the configuration file. You can pass `-conf=<CONFIG_FILE_PATH>` to use a configuration file.

A user-friendly config file generator can be found here: [https://jlopp.github.io/bitcoin-core-config-generator/](https://jlopp.github.io/bitcoin-core-config-generator/).

### Persistent Data
_A configuration file needs to be mounted and referenced with the `-conf` option._  The default path `bitcoind` will look at without setting `-conf=` is _/home/nonroot/.bitcoin/bitcoin.conf_.

The container's persistent data, including configuration and blockchain data should be mounted at _/var/lib/bitcoin_. Be sure to set your `datadir` option in your configuration file to _/var/lib/bitcoin_.

Therefore, the simplest way to get the container up and running would be to mount your config file at _/home/nonroot/.bitcoin/bitcoin.conf_ and forego setting the `-conf` option in the command line.

### User/Group
Because the container uses Chainguard's image as a base, the `bitcoind` process is run as a non-root user. The username and group name is `nonroot`.  The UID and GID are set to _65532_.

### Ports
The container exposes the following ports:
| Port  | Use                                                                   |
| ----- | --------------------------------------------------------------------- |
| 8332  | JSON-RPC communication; for wallets, tools, etc.                      |
| 8333  | peer-to-peer communication; for node to communicate with other nodes  |
| 28332 | ZeroMQ port; for subscribing to specific events using a message queue |

## Dependencies
| Name                                         | Version   |
| -------------------------------------------- | --------- |
| [Chainguard glibc-dynamic](https://images.chainguard.dev/directory/image/glibc-dynamic/versions) | latest |
| [Bitcoin Core](https://github.com/bitcoin/bitcoin) | v27.1.0   |

## License
This project is licensed under the GNU Affero General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

This container image includes compiled [Bitcoin Core](https://github.com/bitcoin/bitcoin) binaries, which is distributed under the terms of the MIT License. The corresponding source code can be obtained [here](https://github.com/bitcoin/bitcoin).

