#!/bin/bash
#
# The MIT License (MIT)
# Copyright (c) 2016 GeoMoose
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 

# stop errors, don't allow undefined variables
set -euo pipefail

function usage()
{
    echo
    echo "This script builds the GeoMoose examples release packages."
    echo
    echo "It is meant to be run from the top level of a gm3 checkout after"
    echo "running  'npm pack'  (which builds the GeoMoose SDK and creates"
    echo "'geomoose-VERSION.tgz')."
    echo
}

# TODO: Take path to gemoose-*.tgz as an optional argument
# TODO: add a --help argument

if [ ! -f "geomoose-*.tgz" ]; then
    echo
    echo "Error: 'geomoose-*.tgz' not found."
    usage
    exit 1
fi

# Get the GeoMoose library version
VERS=$(echo geomoose-*.tgz | sed -e 's/geomoose-\(.*\)\.tgz/\1/')

# Get the GeoMoose library git commit (if available)
# TODO: no guarantee this actually matches what is in the .tgz file
#       The last npm pack run might not even be from a clean working state.
REFS=$(git rev-parse --short HEAD)
if [ -z $REFS ] ; then
    REFS="unknown"
fi

echo "Building version $VERS from commit $REFS"

# make examples package
rm -rf build.tmp
mkdir build.tmp
cd build.tmp

tar xzvf ../geomoose-$VERS.tgz # -> package

mkdir -p gm3-examples/htdocs
mv package/examples/* gm3-examples/htdocs
rmdir package/examples
cp package/LICENSE gm3-examples
cp package/AUTHORS gm3-examples
# TODO: Make a README.txt for the demos
# TODO: Move config.js.example out of htdocs?
cat > gm3-examples/VERSION <<EOF
This is the GeoMoose library and examples version $VERS built from git commit $REFS.
EOF
mv package gm3-examples/htdocs/geomoose

# Ugly hack to pull in JQuery for gm3-examples/mobile
(
  cd gm3-examples/htdocs/mobile
  npm install
)

zip -r gm3-examples-$VERS.zip gm3-examples

# make MS4W examples package
MS4W=../../gm3-admin/ms4w

mkdir -p ms4w/apps
mv gm3-examples ms4w/apps/gm3
cp $MS4W/config.js ms4w/apps/gm3/htdocs/desktop
cp $MS4W/config.js ms4w/apps/gm3/htdocs/mobile

# TODO: s/GeoMoose3/GeoMoose - $VERS/ ?
mkdir -p ms4w/Apache/htdocs
cp $MS4W/gm3.pkg.html ms4w/Apache/htdocs

mkdir -p ms4w/httpd.d
cp $MS4W/httpd_gm3.conf ms4w/httpd.d

zip -r gm3-examples-$VERS-ms4w.zip ms4w

# then to deploy to demo.geomoose.org is just
# unzip gm3-examples-$VERS into /srv/demo/html/3.0
# and copy in config.js and index.html
