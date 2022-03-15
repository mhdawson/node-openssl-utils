#!/bin/bash
export JTHREADS=150
export OPENSSL_TAG="openssl-3.0.2"
export REPO="mhdawson/io.js"
export USERNAME="Michael Dawson"
export EMAIL="midawson@redhat.ca"
export COMMIT_COMMENT="deps: upgrade openssl sources to quictls/$OPENSSL_TAG

This updates all sources in deps/openssl/openssl by:
    $ git clone git@github.com:quictls/openssl.git
    $ cd openssl
    $ git checkout ${OPENSSL_TAG}+quic
    $ cd ../node/deps/openssl
    $ rm -rf openssl
    $ cp -R ../../../openssl openssl
    $ rm -rf openssl/.git* openssl/.travis*
    $ git add --all openssl
    $ git commit openssl"

export COMMIT_COMMENT_ARCH_FILES="deps: update archs files for quictls/$OPENSSL_TAG

After an OpenSSL source update, all the config files need to be
regenerated and committed by:
    $ make -C deps/openssl/config
    $ git add deps/openssl/config
    $ git add deps/openssl/openssl
    $ git commit"

docker build \
  --build-arg JTHREADS="$JTHREADS" \
  --build-arg COMMIT_COMMENT="$COMMIT_COMMENT" \
  --build-arg COMMIT_COMMENT_ARCH_FILES="$COMMIT_COMMENT_ARCH_FILES" \
  --build-arg OPENSSL_TAG="$OPENSSL_TAG" \
  --build-arg REPO="$REPO" \
  --build-arg USERNAME="$USERNAME" \
  --build-arg EMAIL="$EMAIL" \
  . -t openssl-update-builder-main
