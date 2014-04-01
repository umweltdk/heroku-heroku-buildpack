#!/usr/bin/env bash
(
	status "Installing bundler"
	gem install bundler | indent

	status "Installing gems"
	bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin --deployment | indent
)
export PATH=$PATH:vendor/bundle/bin