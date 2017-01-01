#!/usr/bin/env bash

scripts=`dirname ${0}`
root=`dirname ${scripts}`
default="${root}/default.nix"
nodejs=`nix-build -A nodejs --no-out-link ${default}`
PATH="${nodejs}/bin:$PATH"

source "${root}/secrets.txt"
tmpDir=`mktemp -d`

echo "Building node package ..."
nodePackage=`nix-build -A sassSrc --no-out-link ${default}`
cp -R ${nodePackage}/* ${tmpDir}

echo "Generating .npmrc ..."
# npm adduser creates .npmrc file in HOME
HOME=${tmpDir}
echo -e "${NPM_USER}\n${NPM_PASS}\n${NPM_EMAIL}\n" | npm adduser

echo "Publishing ..."
npm publish ${tmpDir}

echo "Cleaning up"
rm -rf ${tmpDir}