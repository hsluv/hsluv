#!/usr/bin/env bash

scripts=`dirname ${0}`
default="$scripts/../default.nix"
haxe=`nix-build -A haxe --no-out-link ${default}`
PATH="${haxe}/bin:$PATH"

echo "Building"
build=`nix-build -A haxelibZip --no-out-link ${default}`

echo "Submitting to Haxelib"
haxelib submit ${build}/hsluv.zip
