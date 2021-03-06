#!/bin/sh

eval `opam config env`
oasis setup
./configure --enable-docs
make doc

if [ -z "$TRAVIS" -o "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "This is not a push Travis-ci build, doing nothing..."
  exit 0
else
  echo "Updating docs on Github pages..."
fi

DOCDIR=.gh-pages
if [ -n "$KEEP" ]; then trap "rm -rf $DOCDIR" EXIT; fi
rm -rf $DOCDIR

git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/xapi-project/nbd $DOCDIR > /dev/null
git -C $DOCDIR rm -rf .
cp _build/api.docdir/* $DOCDIR
git -C $DOCDIR config user.email "travis@travis-ci.org"
git -C $DOCDIR config user.name "Travis"
(cd $DOCDIR; git add *)
git -C $DOCDIR commit --allow-empty -am "Travis build $TRAVIS_BUILD_NUMBER pushed docs to gh-pages"
git -C $DOCDIR push origin gh-pages > /dev/null
