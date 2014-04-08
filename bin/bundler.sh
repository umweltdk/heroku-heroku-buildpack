#!/usr/bin/env bash
(
	if [ -d "$env_dir" ]; then
	  status "Exporting config vars to environment"
	  export_env_dir $env_dir
	fi


	if test -d $cache_dir/.gem/ruby/1.9.1; then
		status "Restoring gems from cache"
		mkdir -p $build_dir/.gem/ruby/1.9.1
		cp -r $cache_dir/.gem/ruby/1.9.1 $build_dir/.gem/ruby/1.9.1
	fi


	status "Installing bundler"
	#gem install bundler |indent
	gem install bundler | indent

	rm -rf $cache_dir/.gem/ruby/1.9.1

	if test -d $BUNDLE_HOME; then
		status "Rebuilding gem cache"
		mkdir -p $cache_dir/.gem/ruby/1.9.1
		cp -r $GEM_HOME $cache_dir/.gem/ruby/1.9.1
	fi


	if test -d $cache_dir/vendor/bundle; then
		status "Restoring bundle directory from cache"
		mkdir -p $build_dir/vendor/bundle
		cp -r $cache_dir/vendor/bundle $build_dir/vendor/bundle
	fi

	status "Installing gems"
	bundle install --gemfile=$build_dir/Gemfile \
				   --without development:test \
				   --path $BUNDLE_HOME \
				   --binstubs $BUNDLE_HOME/bin \
				   --deployment \
		| indent

	#Remove cache
	rm -rf $cache_dir/vendor/bundle

	if test -d $BUNDLE_HOME; then
		status "Rebuilding bundle directory cache"
		mkdir -p $cache_dir/vendor/bundle
		cp -r $BUNDLE_HOME $cache_dir/vendor/bundle
	fi
)