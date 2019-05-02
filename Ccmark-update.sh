#!/usr/bin/env bash

# This script updates files in the Ccmark dependency with those from the
# cmark repository. It automates what was at one point a manual process:
# https://github.com/IBM-Swift/Kitura-Markdown/blob/c02d3f1f1c5d4be4e90bcce841ae7573995ea6b4/Sources/Ccmark/README.md

# Test for existence of cmake
which cmake > /dev/null
if [ $? -gt 0 ]
then
  echo "Install cmake first."
  exit 1
fi

# Test for existence of git
which git > /dev/null
if [ $? -gt 0 ]
then
  echo "Install git first."
  exit 1
fi

# Clone CommonMark repo
# Change repo address to https://github.com/github/cmark to use
# GitHub-Flavored Markdown
git clone https://github.com/commonmark/cmark.git /tmp/cmark

# Build a list of files to copy by listing all files in the 'src' directory
# but removing all of the ones that end in .in
filelist=`ls /tmp/cmark/src/ | sed -E -e 's/(.+)\.in$//g' | sed -E -e 's/(.+)/\/tmp\/cmark\/src\/\1/g' | paste -s -d ' ' -`

# Now copy them
cp $filelist Sources/Ccmark/

here=`pwd`

# Build stuff
mkdir /tmp/cmark/build
cd /tmp/cmark/build
cmake ..
if [ $? -gt 0 ]
then
  echo "Cmake seems to have failed. Not continuing with updating Ccmark."
  exit 2
fi

cd $here
cp /tmp/cmark/build/src/*.h Sources/Ccmark/

# Replace angle brackets in include lines in cmark.h
sed -E -e 's/\#include <(.+)>/\#include \"\1\"/g' Sources/Ccmark/cmark.h > Sources/Ccmark/cmark.h.tmp && mv Sources/Ccmark/cmark.h.tmp Sources/Ccmark/cmark.h

# Remove unwanted main.c file
rm Sources/Ccmark/main.c

rm -rf /tmp/cmark/

echo "Finished updating Ccmark."
