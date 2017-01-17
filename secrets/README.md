# Shared credentials

We are using public key cryptography to share credentials. Contributors' public keys are
stored in PEM format in `/secrets/public`. A plaintext `/secrets.txt` file, which is ignored
by git, is encrypted using each of these public keys and stored in the repo in its encrypted
form. It can be decrypted by anyone posessing a private key that corresponds to one of the
shared public keys.

To decrypt secrets (overwriting `/secrets.txt`):

```
./scripts/secrets.sh --decrypt ~/.ssh/myprivatekey ./secrets/symmetric/myusername.enc.txt
```

After updating `/secrets.txt` or adding a new PEM file to `/secrets/public`, secrets need to be
re-encrypted. To encrypt secrets:

```
./scripts/secrets.sh --encrypt
```

Don't forget to commit re-encrypted secrets after running the command above.

## PEM files

To generate PEM file from public key:

```
ssh-keygen -f ~/.ssh/id_rsa.pub -e -m PKCS8 > myusername.pem
```

## GPG key

To create signed packages (e.g. for Maven Central) we need a GPG key. A GPG key shared by all
the contributors is located in `/secrets`. The private key is protected by a passphrase which 
can be found in `/secrets.txt`. Our shared key is set to expire in 1 year.

Generating GPG key:

    gpg2 --gen-key
    gpg2 --list-keys
    gpg2 --output hsluvcontributors_pub.gpg --armor --export 381DF082
    gpg2 --output hsluvcontributors_sec.gpg --armor --export-secret-key 381DF082
