#!/usr/bin/env bash
(
	GEM_CACHE=$cache_dir/.gem/ruby/1.9.1
	BUNDLE_CACHE=$cache_dir/vendor/bundle

	if [ -d "$env_dir" ]; then
	  status "Exporting config vars to environment"
	  export_env_dir $env_dir
	fi

	#Fetch cache
	if test -d $GEM_CACHE; then
		status "Restoring gems from cache"
		mkdir -p $GEM_HOME
		cp -r $GEM_CACHE $GEM_HOME
	fi


	status "Installing bundler"
	#gem install bundler |indent
	gem install bundler | indent

	#Purge cache
	rm -rf $cache_dir/.gem/ruby/1.9.1

	#Rebuild cache
	if test -d $GEM_HOME; then
		status "Rebuilding gem cache"
		mkdir -p $GEM_CACHE
		cp -r $GEM_HOME $GEM_CACHE
	fi


	if test -d $BUNDLE_CACHE; then
		status "Restoring bundle directory from cache"
		mkdir -p $BUNDLE_HOME
		cp -r $BUNDLE_CACHE $BUNDLE_HOME
	fi

	status "Installing gems"
	bundle install --gemfile=$build_dir/Gemfile \
				   --without development:test \
				   --path $BUNDLE_HOME \
				   --binstubs $BUNDLE_HOME/bin \
				   --deployment \
		| indent

	#Purge cache
	rm -rf $BUNDLE_CACHE

	if test -d $BUNDLE_HOME; then
		status "Rebuilding bundle directory cache"
		mkdir -p $BUNDLE_CACHE
		cp -r $BUNDLE_HOME $BUNDLE_CACHE
	fi
)