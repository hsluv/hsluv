#!/usr/bin/env bash

scripts=`dirname ${0}`
root=`dirname ${scripts}`
default="${root}/default.nix"
awscli=`nix-build -A awscli --no-out-link ${default}`
PATH="${awscli}/bin:$PATH"

source "${root}/secrets.txt"

echo "Building website"
build=`nix-build -A website --no-out-link ${default}`

echo "Syncing website"
aws s3 cp --recursive ${build} s3://www.hsluv.org
