#!/usr/bin/env bash

(
	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8

	export GEM_HOME=$cache_dir/local-gems
	export GEM_PATH=$GEM_PATH/gems

	status "Installing bundler"
	/usr/bin/env gem install bundler

	status "Installing gems"
	$GEM_PATH/bin/bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin --deployment | indent
)
export PATH=$PATH:vendor/bundle/bin