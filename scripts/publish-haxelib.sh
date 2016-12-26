#!/usr/bin/env bash

scripts=`dirname ${0}`
default="$scripts/../default.nix"

echo "Building"
build=`nix-build -A haxelibZip --no-out-link ${default}`
haxe=`nix-build -A haxe --no-out-link ${default}`

echo "Submitting to Haxelib"
${haxe}/bin/haxelib submit ${build}/hsluv.zip
