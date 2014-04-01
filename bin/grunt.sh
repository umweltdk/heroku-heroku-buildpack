#!/usr/bin/env bash

# Check and run Grunt
(
  if [ -f $build_dir/grunt.js ] || [ -f $build_dir/Gruntfile.js ] || [ -f $build_dir/Gruntfile.coffee ]; then
    # get the env vars
    if [ -d "$env_dir" ]; then
      status "Exporting config vars to environment"
      export_env_dir $env_dir
    fi

    # make sure that grunt and grunt-cli are installed locally
    npm install grunt-cli
    npm install grunt
    status "Found Gruntfile, running grunt heroku:$NODE_ENV task"
    $build_dir/node_modules/.bin/grunt heroku:$NODE_ENV
  else
    error "No Gruntfile (grunt.js, Gruntfile.js, Gruntfile.coffee) found"
  fi
)