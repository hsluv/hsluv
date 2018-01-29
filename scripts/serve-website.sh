#!/usr/bin/env bash

scripts=`dirname ${0}`
root=`dirname ${scripts}`

default="${root}/default.nix"
website=`nix-build -A website --no-out-link ${default}`
python=`nix-build -A python --no-out-link ${default}`
PATH="${python}/bin:$PATH"

(cd ${website} && python -m http.server)
