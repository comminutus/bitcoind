########################################################################################################################
# Configuration
########################################################################################################################
# Core Config
ARG bitcoin_version=27.1

# Ports:
# 8332: JSON-RPC
# 8333: peers
# 28332: ZMQ
ARG ports='8332 8333 28332'

# Defaults
ARG build_dir=/tmp/build
ARG license_dir=$build_dir/licenses
ARG dist_dir=$build_dir/dist
ARG data_dir=/var/lib/bitcoin


########################################################################################################################
# Build Image
########################################################################################################################
FROM cgr.dev/chainguard/wolfi-base:latest as build
ARG build_dir license_dir dist_dir bitcoin_version
ARG bitcoin_license_url=https://raw.githubusercontent.com/bitcoin/bitcoin/master/COPYING
ARG base_archive_url=https://bitcoincore.org/bin/bitcoin-core-$bitcoin_version

# Options for tools
ARG build_packages='gpg gpg-agent wget'
ARG gpg='gpg --batch'
ARG wget='wget -q'

# Copy assets
WORKDIR $build_dir
COPY builder-keys ./builder-keys/
COPY LICENSE $license_dir

# Install build packages
RUN apk add $build_packages

# Download SHA-256 hashes and signatures; verify signatures
RUN $wget $base_archive_url/SHA256SUMS
RUN $wget $base_archive_url/SHA256SUMS.asc
RUN $gpg --import builder-keys/*
RUN $gpg --verify SHA256SUMS.asc SHA256SUMS

RUN set -ex                                                         && \
  platform="$(uname -a | awk '{print tolower($1)}')"                && \
  arch="$(uname -m)"                                                && \
  archive="bitcoin-${bitcoin_version}-$arch-$platform-gnu.tar.gz"   && \
  echo "$archive" > archive.txt

# Download Bitcoin
RUN $wget "$base_archive_url/$(cat archive.txt)"

# Verify Bitcoin
RUN grep "$(cat archive.txt)" "SHA256SUMS" | sha256sum -c

# Extract archive
RUN mkdir -p "$dist_dir" bitcoin
RUN tar -xz --strip-components 1 -C bitcoin -f "$(cat archive.txt)"
RUN cp bitcoin/bin/bitcoind $dist_dir

# Download license file
RUN $wget -P $license_dir $bitcoin_license_url


########################################################################################################################
# Final image
########################################################################################################################
FROM cgr.dev/chainguard/glibc-dynamic:latest-dev as final
ARG dist_dir license_dir ports

# Install binaries
COPY --from=build $dist_dir /usr/local/bin
COPY --from=build $license_dir /usr/share/licenses/bitcoin

# Setup a volume for blockchain
VOLUME /var/lib/bitcoin

# Expose ports
EXPOSE $ports

# Run entrypoint script
ENTRYPOINT ["/usr/local/bin/bitcoind", "-datadir=/var/lib/bitcoin"]
