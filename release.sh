#!/bin/bash

VERS=$1
if [ -z "$VERS" ]; then
  VERS="master"
fi

EXAMPLE=$2
if [ -z "$EXAMPLE" ]; then
  EXAMPLE="desktop"
fi

HOME=`pwd`

APPDIR=build/gm3-$EXAMPLE-example/

rm -rf build/

# clone the app repo
git clone https://github.com/geomoose/gm3/ $APPDIR/geomoose/
cd $APPDIR/geomoose/

# git checkout $VERS
git fetch origin demos-to-examples
git checkout demos-to-examples 
COMMIT_VERS=`git rev-parse --short HEAD`

# chuck the repo data.
rm .gitignore
rm -rf .git

# copy the config.js.example
cp examples/config.js.example ..
# copy the example we're building
cp -r examples/$EXAMPLE/* ..

# now remove all the rest of the examples
rm -r examples/

# checkout the needed dependencies.
npm install 
grunt build

# the node modules don't need to stick around
#  after the build is done.
rm -r node_modules/

# back to our working dir.
cd $HOME

# head to the build dir and zip up what we got.
cd build/

# TODO: rename "VERS" to "nightly" when "VERS" is master.
#       Should the commit hash be included for versions?!?
zip -r gm3-$EXAMPLE-example-$VERS-$COMMIT_VERS.zip *
