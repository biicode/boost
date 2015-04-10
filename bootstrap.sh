#!/bin/sh

git clone https://github.com/biicode/boost.git biicode-boost

mkdir -p blocks
cd biicode-boost
./generate $1 --no-publish
cp -r -p blocks/* ../blocks
