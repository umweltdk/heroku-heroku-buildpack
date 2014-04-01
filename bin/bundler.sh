#!/usr/bin/env bash

(
	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8
	status "Installing bundler"
	gem install bundler | indent

	status "Installing gems"
	bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin --deployment | indent
)
export PATH=$PATH:vendor/bundle/bin