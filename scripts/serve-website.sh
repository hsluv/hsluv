#!/usr/bin/env bash

scripts=`dirname ${0}`
root=`dirname ${scripts}`

default="${root}/default.nix"
website=`nix-build -A website --no-out-link ${default}`
python3=`nix-build -A python3 --no-out-link ${default}`
PATH="${python3}/bin:$PATH"

(cd ${website} && python -m http.server)
