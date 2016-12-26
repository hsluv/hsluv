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
#tmpDir=`mktemp -d`

#echo -e "[pypi]" >> ${tmpDir}/.pypirc
#echo -e "username:${PYPI_USERNAME}" >> ${tmpDir}/.pypirc
#echo -e "password:${PYPI_PASSWORD}" >> ${tmpDir}/.pypirc
#HOME=${tmpDir}
#
#echo ${tmpDir}
#
#echo -e "Fetching Python source ..."
#pythonSrc=`nix-build -A pythonSrc --no-out-link ${default}`
#
#python3 ${pythonSrc}/setup.py sdist upload