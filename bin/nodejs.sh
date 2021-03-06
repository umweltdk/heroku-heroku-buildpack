#!/usr/bin/env bash
(
  # Output npm debug info on error
  trap cat_npm_debug_log ERR

  # Look in package.json's engines.node field for a semver range
  semver_range=$(cat $build_dir/package.json | $bp_dir/vendor/jq -r .engines.node)

  # Resolve node version using semver.io
  node_version=$(curl --silent --get --data-urlencode "range=${semver_range}" https://semver.io/node/resolve)

  # Recommend using semver ranges in a safe manner
  if [ "$semver_range" == "null" ]; then
    protip "Specify a node version in package.json"
    semver_range=""
  elif [ "$semver_range" == "*" ]; then
    protip "Avoid using semver ranges like '*' in engines.node"
  elif [ ${semver_range:0:1} == ">" ]; then
    protip "Avoid using semver ranges starting with '>' in engines.node"
  fi

  # Output info about requested range and resolved node version
  if [ "$semver_range" == "" ]; then
    status "Defaulting to latest stable node: $node_version"
  else
    status "Requested node range:  $semver_range"
    status "Resolved node version: $node_version"
  fi

  # Download node from Heroku's S3 mirror of nodejs.org/dist
  status "Downloading and installing node"
  node_url="http://s3pository.heroku.com/node/v$node_version/node-v$node_version-linux-x64.tar.gz"
  curl $node_url -s -o - | tar xzf - -C $build_dir

  # Move node (and npm) into ./vendor and make them executable
  mv $build_dir/node-v$node_version-linux-x64 $NODE_HOME
  chmod +x $NODE_HOME/bin/*

  # Run subsequent node/npm commands from the build path
  cd $build_dir

  # If node_modules directory is checked into source control then
  # rebuild any native deps. Otherwise, restore from the build cache.
  if test -d $NODE_MODULES_HOME; then
    status "Found existing node_modules directory; skipping cache"
    status "Rebuilding any native dependencies"
    npm rebuild 2>&1 | indent
  elif test -d $cache_dir/node/node_modules; then
    status "Restoring node_modules directory from cache"
    cp -r $cache_dir/node/node_modules $build_dir/

    status "Pruning cached dependencies not specified in package.json"
    npm prune 2>&1 | indent

    if test -f $cache_dir/node/.heroku/node-version && [ $(cat $cache_dir/node/.heroku/node-version) != "$node_version" ]; then
      status "Node version changed since last build; rebuilding dependencies"
      npm rebuild 2>&1 | indent
    fi

  fi

  # Scope config var availability only to `npm install`
  (
    if [ -d "$env_dir" ]; then
      status "Exporting config vars to environment"
      export_env_dir $env_dir
    fi

    status "Installing dependencies"
    # Make npm output to STDOUT instead of its default STDERR
    npm install --userconfig $build_dir/.npmrc --production 2>&1 | indent
  )

  # Check and run Grunt
  (
    GRUNTFILE=$(find $build_dir -iname "grunt*" -maxdepth 1)
    if [ -n "$GRUNTFILE" ]; then
      # get the env vars
      if [ -d "$env_dir" ]; then
        status "Exporting config vars to environment"
        export_env_dir $env_dir
      fi

      # make sure that grunt and grunt-cli are installed locally
      npm install grunt-cli grunt | indent
      npm install | indent #install devDependencies
      status "Found Gruntfile, running grunt heroku:$NODE_ENV task"

      $build_dir/node_modules/.bin/grunt heroku:$NODE_ENV | indent
    else
      warn "No Gruntfile (grunt.js, Gruntfile.js, Gruntfile.coffee) found"
    fi
  )

  # Check and run Gulp
  (
    GULPFILE=$(find $build_dir -iname "gulp*" -maxdepth 1)
    if [ -n "$GULPFILE" ]; then
      # get the env vars
      if [ -d "$env_dir" ]; then
        status "Exporting config vars to environment"
        export_env_dir $env_dir
      fi

      # make sure that gulp is installed locally
      npm install gulp | indent
      npm install | indent #install devDependencies
      status "Found Gulpfile, running `gulp heroku`"

      $build_dir/node_modules/.bin/gulp heroku:$NODE_ENV | indent
    else
      warn "No Gulpfile found"
    fi
  )

  # Persist goodies like node-version in the slug
  mkdir -p $build_dir/.heroku

  # Save resolved node version in the slug for later reference
  echo $node_version > $build_dir/.heroku/node-version

  # Purge node-related cached content, being careful not to purge the top-level
  # cache, for the sake of heroku-buildpack-multi apps.
  rm -rf $cache_dir/node_modules # (for apps still on the older caching strategy)
  rm -rf $cache_dir/node
  mkdir -p $cache_dir/node

  # If app has a node_modules directory, cache it.
  if test -d $build_dir/node_modules; then
    status "Caching node_modules directory for future builds"
    cp -r $build_dir/node_modules $cache_dir/node
  fi

  # Copy goodies to the cache
  cp -r $build_dir/.heroku $cache_dir/node

  status "Cleaning up node-gyp and npm artifacts"
  rm -rf "$build_dir/.node-gyp"
  rm -rf "$build_dir/.npm"

  # If Procfile is absent, try to create one using `npm start`
  if [ ! -e $build_dir/Procfile ]; then
    npm_start=$(cat $build_dir/package.json | $bp_dir/vendor/jq -r .scripts.start)

    # If `scripts.start` is set in package.json, or a server.js file
    # is present in the app root, then create a default Procfile
    if [ "$npm_start" != "null" ] || [ -f $build_dir/server.js ]; then
      status "No Procfile found; Adding npm start to new Procfile"
      echo "web: npm start" > $build_dir/Procfile
    else
      status "Procfile not found and npm start script is undefined"
      protip "Create a Procfile or specify a start script in package.json"
    fi
  fi


  # Post package.json to nomnom service
  # Use a subshell so failures won't break the build.
  (
    curl \
      --data @$build_dir/package.json \
      --fail \
      --silent \
      --request POST \
      --header "content-type: application/json" \
      https://nomnom.heroku.com/?request_id=$REQUEST_ID \
      > /dev/null
  ) &
)