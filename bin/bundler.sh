#!/usr/bin/env bash

set -e            # fail fast
set -o pipefail   # don't ignore exit codes when piping output
# set -x          # enable debugging

# Configure directories
build_dir=$1
cache_dir=$2
env_dir=$3

bp_dir=$(cd $(dirname $0); cd ..; pwd)

# Load some convenience functions like status(), error(), and indent()
source $bp_dir/bin/common.sh

status "Installing bundler"
gem install bundler | indent

status "Installing gems"
bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin --deployment | indent