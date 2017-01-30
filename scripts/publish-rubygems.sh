#!/usr/bin/env bash

scripts=`dirname ${0}`
root=`dirname ${scripts}`
default="${root}/default.nix"
ruby=`nix-build -A ruby --no-out-link ${default}`
rubySrc=`nix-build -A rubySrc --no-out-link ${default}`

tmpDir=`mktemp -d`

PATH="${ruby}/bin:$PATH"

source "${root}/secrets.txt"

cd ${tmpDir}
gem build ${rubySrc}/hsluv.gemspec
echo -e "${RUBYGEMS_EMAIL}\n${RUBYGEMS_PASSWORD}\n" | gem push hsluv-1.0.0.gem
