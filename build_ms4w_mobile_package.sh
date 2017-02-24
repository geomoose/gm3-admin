#!/bin/bash

VERS=$1
if [ -z "$VERS"]; then
  VERS="master"
fi

HOME=`pwd`

APPDIR=build/ms4w/apps/gm3-demo-mobile

rm -rf build/

# clone the app repo
git clone https://github.com/geomoose/gm3-demo-mobile/ $APPDIR/htdocs/
cd $APPDIR/htdocs/

# TODO: checkout the desired version.
git checkout $VERS
COMMIT_VERS=`git rev-parse --short HEAD`

# chuck the repo.
rm .gitignore
rm -rf .git

# checkout the needed dependencies.
npm install --production

# remove the built-in zip files.
find . -name "*.zip" -exec rm {} \;
# and strip out all the demos.
find . -name demos -exec rm -r {} \;

# back to our working dir.
cd $HOME

# hack the configuration from the default
#  "linux" style configuration.
# aka, migrate away from @theduckylittle's style.

cat $APPDIR/htdocs/mobile.js \
   | sed "s/mapserver_url: '.mapserver.cgi.bin.mapserv'/mapserver_url: '\/cgi-bin\/mapserv.exe'/" \
   | sed "s/mapfile_root: '.data.'/mapfile_root: '\/ms4w\/apps\/gm3\-demo\-data\/'/" \
   > /tmp/mobile.js

cp /tmp/mobile.js $APPDIR/htdocs/mobile.js

# now include the specific MS4W configuration bits.
mkdir -p build/ms4w/http.d

APACHEDIR=build/ms4w/Apache/htdocs/
mkdir -p $APACHEDIR
cp ms4w/gm3-demo-mobile.pkg.html $APACHEDIR

CONFDIR=build/ms4w/httpd.d
mkdir -p $CONFDIR
cp ms4w/gm3-demo-mobile.conf $CONFDIR

cd build/
zip -r ms4w-gm3-demo-mobile-$VERS-$COMMIT_VERS.zip *
