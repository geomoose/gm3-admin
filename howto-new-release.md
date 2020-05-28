# Create a workspace

```
  mkdir tmp
  cd tmp
  git clone git@github.com:geomoose/gm3.git
  cd gm3
```

# Verify the commit is good.

Only continue if the following completes successfully.

```
  ./install_test_deps.sh
  npm test
```

Note: `npm install` doesn't install all the packages needed for complete testing because it testing requires two packages that require being built from C modules.  This causes no end of trouble for people trying to install/build GeoMoose on systems without integrated system wide compilers (looking at you Windows).

# Bump the version number

Updates package.json, creates a commit and an annotated git tag.

```
  npm version major (or minor or patch ...)
```

# Push the changes to main gm3 repo

This will trigger a build on https://demo.geomoose.org.  Wait for new files in /downloads/ before continuing.  Note: there is currently a race condition here if you don't wait long enough or if someone else pushes to master before you complete the next step.

These files can also be created manually using the other scripts in this repo.


```
  git push --tags origin HEAD
```

# Bump master for next dev-version

We don't want new dev commits overwriting our release.  (package.json needs to be updated).

```
  #npm version prepatch would be more standard
  npm version --no-git-tag-version 3.0.1-beta
  git add package.json package-lock.json
  git commit -m 'Bump master to next dev version'
  git push
```

# Also tag gm3-demo-data (it also gets built as part of the release)

```
  cd ..
  git clone git@github.com:geomoose/gm3-demo-data.git
  cd gm3-demo-data
  git tag -a v3.0.0
  git push --tags
```

# Cleanup old betas in downloads directory

Files on www.geomoose.org

# Publish to NPM

```
   git checkout v3.6.0   # checkout the version to publish
   git clean -fxd        # make sure don't have extra files hanging out
   npm login             # login into npm
   npm install           # install node_modules
   npm publish           # build and upload to npm
```

# Update webpages/announcements

	- geomoose-website/source/news.rst
  - geomoose-website/source/download.rst
  - geomoose-website/source/releases/<version>.rst
  - Announce on geomoose-users list

