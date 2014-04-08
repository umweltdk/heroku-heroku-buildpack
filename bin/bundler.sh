#!/usr/bin/env bash
(
	status "Installing bundler"
	/usr/bin/env gem install bundler |indent

	status "Installing gems"
	bundle install --gemfile=$build_dir/Gemfile \
				   --without development:test \
				   --path $build_dir/vendor/bundle \
				   --binstubs $build_dir/vendor/bundle/bin \
				   --deployment \
		| indent
)