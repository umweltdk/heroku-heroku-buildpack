#!/usr/bin/env bash
(
    GEM_BUILD=$build_dir/.gem
    GEM_CACHE=$cache_dir/.gem

    BUNDLE_BUILD=$build_dir/vendor/bundle
    BUNDLE_CACHE=$cache_dir/vendor/bundle

    if [ -d "$env_dir" ]; then
      status "Exporting config vars to environment"
      export_env_dir $env_dir
    fi

    #Fetch cache
    if test -d $GEM_CACHE; then
    #     status "Restoring gems from cache"
    #     mkdir -p $GEM_BUILD
    #     cp -R $GEM_CACHE $GEM_BUILD
    #     status "Installing bundler"
    #     gem update bundler --no-ri --no-rdoc | indent
    # else
        status "Updating bundler"
        echo $PATH
        gem install bundler --no-ri --no-rdoc | indent
    fi

    echo $GEM_HOME | indent
    ls -R $GEM_HOME
    ls -R $GEM_CACHE

    #Purge cache
    rm -rf $GEM_CACHE

    #Rebuild cache
    if test -d $GEM_BUILD; then
        status "Rebuilding gem cache"
        mkdir -p $GEM_CACHE
        cp -R $GEM_BUILD $GEM_CACHE
    fi


    if test -d $BUNDLE_CACHE; then
        status "Restoring bundle directory from cache"
        mkdir -p $BUNDLE_BUILD
        cp -R $BUNDLE_CACHE $BUNDLE_BUILD
    fi

    status "Installing gems"
    bundle install --gemfile=$build_dir/Gemfile \
                   --without development:test \
                   --path $BUNDLE_BUILD \
                   --binstubs $BUNDLE_BUILD/bin \
                   --deployment \
        | indent

    #Purge cache
    rm -rf $BUNDLE_CACHE

    if test -d $BUNDLE_BUILD; then
        status "Rebuilding bundle directory cache"
        mkdir -p $BUNDLE_CACHE
        cp -R $BUNDLE_BUILD $BUNDLE_CACHE
    fi
)