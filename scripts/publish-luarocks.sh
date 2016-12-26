#!/usr/bin/env bash

scripts=`dirname ${0}`
root=`dirname ${scripts}`
default="${root}/default.nix"
luarocks=`nix-build -A luarocks --no-out-link ${default}`
luaSrc=`nix-build -A luaSrc --no-out-link ${default}`

PATH="${luarocks}/bin:$PATH"

source "${root}/secrets.txt"

export LUA_PATH="${luaSrc}/?.lua"

luarocks upload ${luaSrc}/*.rockspec --api-key=${LUAROCKS_API_KEY}
