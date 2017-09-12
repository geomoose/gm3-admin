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
  npm install
  npm test
```

# Bump the version number

Updates package.json, creates a commit and an annotated git tag.

```
  npm version major (or minor or patch ...)
```

# Push the changes to main gm3 repo

This will trigger a build on www.geomoose.org.  Wait for new files in /downloads/ before continuing.  Note: there is currently a race condition here if you don't wait long enough or if someone else pushes to master before you complete the next step.

These files can also be created manually using the other scripts in this repo.


```
  git push --tags HEAD
```

# Bump master for next dev-version

We don't want new dev commits overwriting our release.  (package.json needs to be updated).

```
  #npm version prepatch would be more standard
  npm version --no-git-tag-version 3.0.1-beta
  git add package.json
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
