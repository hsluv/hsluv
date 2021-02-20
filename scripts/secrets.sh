#!/usr/bin/env bash

scripts=`dirname ${0}`
root=`dirname ${scripts}`

# Use OpenSSL from nixpkgs if available
if [ -x "$(command -v nix-shell)" ];
then
    default="${root}/default.nix"
    openssl=`nix-build -A openssl --no-out-link ${default}`
    PATH="${openssl}/bin:$PATH"
fi

opensslBin="$(command -v openssl)"
if [ -x "${opensslBin}" ];
then
    echo "Using openssl: ${opensslBin}"
else
    echo "ERROR: Could not find openssl binary"
    exit 1
fi

secretsTxt="${root}/secrets.txt"
secretsEnc="${root}/secrets/secrets.enc.txt"
symmetric="${root}/secrets/symmetric"

command="$1"
if [ "${command}" = "--encrypt" ];
then
    echo "Generating symmetric key  ..."
    symmetric=`openssl rand -hex 32`

    rm ${root}/secrets/symmetric/*

    for keyFile in ${root}/secrets/public/*
    do
        keyName="$(basename ${keyFile} .pem)"
        echo "Encrypting symmetric key with ${keyName}.pem ..."
        echo "${symmetric}" \
            | openssl rsautl -encrypt -inkey ${keyFile} -pubin \
            | openssl enc -base64 \
            > ${root}/secrets/symmetric/${keyName}.enc.txt
    done

    echo "Encrypting secrets.txt    ..."
    cat ${secretsTxt} \
        | openssl enc -pbkdf2 -salt -pass pass:${symmetric} \
        | openssl enc -base64 \
        > ${secretsEnc}

    echo "Secrets:        ${secretsEnc}"
elif [ "${command}" = "--decrypt" ];
then
    privateKey="$2"
    symmetricEnc="$3"
    if [ -f "${privateKey}" -a -f "${symmetricEnc}" ];
    then
        echo "Decrypting symmetric key from ${symmetricEnc} ..."
        symmetric=$(cat ${symmetricEnc} \
            | openssl enc -base64 -d \
            | openssl rsautl -inkey ${privateKey} -decrypt)
        echo "Decrypting secrets.txt ..."
        cat ${secretsEnc} \
            | openssl enc -base64 -d \
            | openssl enc -d -pbkdf2 -pass pass:${symmetric} \
            > ${secretsTxt}

    else
        echo "ERROR: Missing or invalid PRIVATE_KEY and/or SYMMETRIC_ENC"
        exit 1
    fi

else
    echo "ERROR: Missing command: --encrypt or --decrypt PRIVATE_KEY"
    exit 1
fi
