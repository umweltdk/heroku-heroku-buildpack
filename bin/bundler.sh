#!/usr/bin/env bash
(
	if [ -d "$env_dir" ]; then
	  status "Exporting config vars to environment"
	  export_env_dir $env_dir
	fi

	status "Installing bundler"
	#gem install bundler |indent
	gem install bundler | indent

	status "Installing gems"
	bundle install --gemfile=$build_dir/Gemfile \
				   --without development:test \
				   --path $BUNDLE_HOME \
				   --binstubs $BUNDLE_HOME/bin \
				   --deployment \
		| indent
)