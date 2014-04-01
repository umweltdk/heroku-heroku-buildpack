#!/usr/bin/env bash

(
	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8

	export GEM_HOME=$build_dir/.gem/ruby/1.9.1

	PATH="$GEM_HOME/bin:$PATH"

	status "Installing bundler"
	/usr/bin/env gem install bundler | indent

	status "Installing gems"
	bundle install --without development:test \
				   --path $build_dir/vendor/bundle \
				   --binstubs $build_dir/vendor/bundle/bin \
				   --deployment \
		| indent

	status "Building ruby runtime environment"
	mkdir -p $build_dir/.profile.d
	echo "export PATH=\"\$HOME/.gem/ruby/1.9.1/bin:\$HOME/vendor/bundle/bin:\$PATH\"" > $build_dir/.profile.d/ruby.sh
)
export PATH="$GEM_HOME/bin:$build_dir/vendor/bundle/bin:$PATH"