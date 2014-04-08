#Avoid ruby problems
LANG=en_US.UTF-8
LC_ALL=$LANG

GEM_HOME=$HOME/.gem/ruby/1.9.1
BUNDLE_HOME=$HOME/vendor/bundle
PATH=$GEM_HOME/bin:$BUNDLE_HOME/bin:$PATH

export LANG LC_ALL PATH GEM_HOME