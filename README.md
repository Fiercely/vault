# This is a simple encrypt/decrypt script to allow for encryption of .env files, or any others.

# Usage with docker

## Encrypting

#### Encrypt with specified password as argument in -k

    docker run --rm -v $PWD:/stuff -w /stuff fiercely/vault encrypt -k foo .envfile

#### Encrypt without specifying password as argument

    #Docker needs to run in interactive mode for the dialog prompt for password to show
    docker run --rm  -it -v $PWD:/stuff -w /stuff fiercely/vault encrypt .envfile

#### Encrypt with specified cipher (Defaults to aes-256-cbc)

    docker run --rm  -it -v $PWD:/stuff -w /stuff fiercely/vault -c aes-128-cbc  encrypt .envfile

## Decrypting

For all decrypting operations both `cipher` and `password` must match those of the encryption

#### Decrypt with specified password as argument in -k

    docker run --rm -v $PWD:/stuff -w /stuff fiercely/vault decrypt -k foo .envfile

#### Decrypt without specifying password as argument

    #Docker needs to run in interactive mode for the dialog prompt for password to show
    docker run --rm  -it -v $PWD:/stuff -w /stuff fiercely/vault decrypt .envfile

#### Decrypt with specified cipher (Defaults to aes-256-cbc)

    docker run --rm  -it -v $PWD:/stuff -w /stuff fiercely/vault -c aes-128-cbc  decrypt .envfile