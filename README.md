Umwelt Heroku Buildpack
=======================

Usage
-----

Example usage for a new app:

```sh
heroku create --buildpack https://bitbucket.org/umwelt/umwelt-heroku-buildpack.git
```

Or for an existing app:

```sh
heroku git:remote -a <APP_NAME>
heroku config:set BUILDPACK_URL=https://bitbucket.org/umwelt/umwelt-heroku-buildpack.git
```

Then:

```sh
git push heroku <BRANCH>:master
```

The buildpack will detect that your app has a `package.json` and a `Gemfile` in the root. It then proceeds to build the project in approximately the following fashion:

```sh
bundle install
npm install
#EITHER
grunt heroku:$NODE_ENV #typically production
#OR
guld heroku:$NODE_ENV
```