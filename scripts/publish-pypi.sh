#!/usr/bin/env bash

scripts=`dirname ${0}`
root=`dirname ${scripts}`
default="${root}/default.nix"
python3=`nix-build -A python3 --no-out-link ${default}`
twine=`nix-build -A twine --no-out-link ${default}`
pythonDist=`nix-build -A pythonDist --no-out-link ${default}`

PATH="${python3}/bin:$PATH"
PATH="${twine}/bin:$PATH"

source "${root}/secrets.txt"

twine upload --username ${PYPI_USERNAME} --password ${PYPI_PASSWORD} ${pythonDist}/*
