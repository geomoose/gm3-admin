#!/bin/bash

if [ -z "$VERS" ]; then
  VERS="master"
fi

HOME=`pwd`

APPDIR=build/ms4w/apps/gm3/htdocs/

rm -rf build/

# clone the app repo
git clone https://github.com/geomoose/gm3/ $APPDIR/geomoose/
cd $APPDIR/geomoose/

# git checkout $VERS
git fetch origin $VERS
git checkout $VERS
COMMIT_VERS=`git rev-parse --short HEAD`

# chuck the repo data.
rm .gitignore
rm -rf .git

# copy the config.js.example
cp examples/config.js.example ..
# copy the example we're building
cp -r examples/* ..

# now remove all the rest of the examples
rm -r examples/

# checkout the needed dependencies.
npm install 

# grunt build

# the node modules don't need to stick around
#  after the build is done.
rm -r node_modules/

# back to our working dir.
cd $HOME

cp ms4w/config.js $APPDIR/desktop/config.js
cp ms4w/config.js $APPDIR/mobile/config.js

APACHEDIR=build/ms4w/Apache/htdocs/
mkdir -p $APACHEDIR
cp ms4w/gm3.pkg.html $APACHEDIR

CONFDIR=build/ms4w/httpd.d
mkdir -p $CONFDIR
cp ms4w/httpd_gm3.conf $CONFDIR

cd build/
zip -r ms4w-gm3-$VERS-$COMMIT_VERS.zip *
