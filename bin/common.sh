#!/usr/bin/env bash

status() {
  echo "-----> $*"
}

error() {
  echo " !     $*" >&2
  exit 1
}

indent() {
  c='s/^/       /'
  case $(uname) in
    Darwin) sed -l "$c";; # mac/bsd sed: -l buffers on line boundaries
    *)      sed -u "$c";; # unix/gnu sed: -u unbuffered (arbitrary) chunks of data
  esac
}
