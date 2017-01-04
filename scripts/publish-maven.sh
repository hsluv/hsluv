#!/usr/bin/env bash

scripts=`dirname ${0}`
root=`dirname ${scripts}`
default="${root}/default.nix"
maven=`nix-build -A maven --no-out-link ${default}`
javaSrc=`nix-build -A javaSrc --no-out-link ${default}`

PATH="${javaSrc}/bin:$PATH"
tmpDir=`mktemp -d`
cp -R ${javaSrc}/* "${tmpDir}"

source "${root}/secrets.txt"

cd "${tmpDir}"

ls

mvn -e deploy
#mvn versions:set -DnewVersion=0.1

# export LUA_PATH="${luaSrc}/?.lua"

# luarocks upload ${luaSrc}/*.rockspec --api-key=${LUAROCKS_API_KEY}
