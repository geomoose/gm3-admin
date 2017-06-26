#!/bin/bash
#
# The MIT License (MIT)
# Copyright (c) 2017 GeoMoose
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

# stop on errors, don't allow undefined variables
set -euo pipefail

function usage()
{
    echo
    echo "This script builds the GeoMoose demo data packages used by the"
    echo "example applications."
    echo
    echo "It is meant to be run from the top level of a gm3-demo-data checkout"
    echo
}

if [ ! -f geomoose_globals.map ]; then
    echo
    echo "Error: 'geomoose_globals.map' not found.  Are you in a gm3-demo-data repo?"
    usage
    exit 1
fi

#REFS=$(git rev-parse --short HEAD)
# Returns the most recent annotated (or signed) tag + any additional commits
REFS=$(git describe)
if [ -z $REFS ] ; then
    REFS="unknown"
fi

echo "Building from $REFS"

# make examples package
rm -rf build.tmp
mkdir build.tmp
cd build.tmp

mkdir -p gm3-demo-data
cat > gm3-demo-data/VERSION <<EOF
This is the GeoMoose demo data from version $REFS.
EOF

rsync -r --exclude-from=../.gitignore --exclude=.git --exclude=.gitignore --exclude=build.tmp .. ./gm3-demo-data

# make Linux gm3-demo-data package
#tar cJvf gm3-demo-data-$REFS.txz --owner=0 --group=0 gm3-demo-data
zip -r gm3-demo-data-$REFS.zip gm3-demo-data

# make MS4W gm3-demo-data package
MS4W=../../gm3-admin/ms4w

mkdir -p ms4w/apps
mv gm3-demo-data ms4w/apps

# Set MS4W temp directory
sed -i \
    -e 's/^IMAGEPATH/## IMAGEPATH/' \
    -e 's/^# IMAGEPATH/IMAGEPATH/' \
    ms4w/apps/gm3-demo-data/temp_directory.map

# TODO: s/GeoMoose3/GeoMoose - $VERS/ ?
mkdir -p ms4w/Apache/htdocs
cp $MS4W/gm3-demo-data.pkg.html ms4w/Apache/htdocs

zip -r gm3-demo-data-$REFS-ms4w.zip ms4w
