#!/bin/bash

VERS=$1
if [ -z "$VERS"]; then
  VERS="master"
fi

HOME=`pwd`

APPDIR=build/ms4w/apps/gm3-demo-data

rm -rf $APPDIR

## Clone the data repo
git clone https://github.com/geomoose/gm3-demo-data/ $APPDIR

## Check out the version specified in $1
cd $APPDIR
git checkout $VERS
COMMIT_VERS=`git rev-parse --short HEAD`
# remove the git-history and other bits unneeded.
rm .gitignore
rm -rf .git

# return to the 'home'
cd $HOME

# add a small HTML indicator that the data 
#  has been installed.
APACHEDIR=build/ms4w/Apache/htdocs/
mkdir -p $APACHEDIR
cp ms4w/gm3-demo-data.pkg.html $APACHEDIR

# package up the data.
cd build/
zip -r ms4w-gm3-demo-data-$VERS-$COMMIT_VERS.zip *
