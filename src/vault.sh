#!/bin/bash

set -e
declare -a gFile
declare -a gFileOut

vault::cleanUp() {
    rm /tmp/$gFile
    rm /tmp/$gFileOut.bk
}

vault::revertAll() {
    vault::revertToPlace
}

vault::clearFileContents() {
    > /tmp/$fileOutput.bk
}

vault::makeTmpCopy() {
    file=$gFile
    fileOutput=$gFileOut
    cp -a $file "/tmp/$file"
    if [ ! -f $fileOutput ]; then
        cp -a $file "/tmp/$fileOutput.bk"
    else
        cp -a $fileOutput "/tmp/$fileOutput.bk"
    fi

}

vault::revertToPlace() {
    file=$gFileOut
    cp -a /tmp/$file.bk $file
}

vault::containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

vault::getKey() {
    if ! [ -z $DOTENV_PASSWORD ]; then
        echo $DOTENV_PASSWORD
        return 0
    fi

    if [ -e .dotenv-password ]; then
        cat .dotenv-password
        return 0
    fi

    read -p 'Please input password and press Return:' -s DOTENV_PASSWORD
    echo $DOTENV_PASSWORD
}

vault::getKeyInLine() {
    echo $1 | sed -r 's/(.+?)=.+$/\1/'
}

vault::getValueInLine() {
    echo $1 | sed -r 's/.+?=(.+)$/\1/'
}

vault::encryptVarsInFile() {
    password=$2
    cipher=$3
    fileOutput=$4
    vars=(${@:5})
    vault::clearFileContents
    cat $1 | while read line
    do
        key=`vault::getKeyInLine $line`
        value=`vault::getValueInLine $line`

        if vault::containsElement $key ${vars[@]}; then
            value=`echo $value | openssl $cipher -A -base64 -k $password -e`
            echo "$key=$value" >> /tmp/$fileOutput.bk
        else
            echo "$key=$value" >> /tmp/$fileOutput.bk
        fi
    done
}

vault::decryptVarsInFile() {
    password=$2
    cipher=$3
    fileOutput=$4
    vars=(${@:5})
    vault::clearFileContents
    cat $1 | while read line
    do
        key=`vault::getKeyInLine $line`
        value=`vault::getValueInLine $line`

        if vault::containsElement $key ${vars[@]}; then
            value=`echo $value | openssl $cipher -A -base64 -k $password -d`
            echo "$key=$value" >> /tmp/$fileOutput.bk
        else
            echo "$key=$value" >> /tmp/$fileOutput.bk
        fi
    done
}

vault::encryptFile() {
    file=$1
    password=$2
    cipher=$3
    outputFile=$4
    openssl $cipher -base64 -k $password -e -in /tmp/$file -out /tmp/$outputFile.bk

}

vault::decryptFile() {
    file=$1
    password=$2
    cipher=$3
    outputFile=$4
    openssl $cipher -base64 -k $password -d -in /tmp/$file -out /tmp/$outputFile.bk
}

vault::encrypt() {
    gFile=$1
    file=$1
    key=$2
    cipher=$3
    gFileOut=$4
    fileOutput=$4
    vars=(${@:5})
    vault::makeTmpCopy
    if [ -z $key ]; then
        key=`vault::getKey`
    fi

    if ! [ -e "$file" ]; then
        echo 'File not found' 1>&2
        exit 2
    fi

    if [ ${#vars[@]} -eq 1 ] && [ ${vars[0]} == "vault_empty_array" ]; then
        vault::encryptFile $file $key $cipher $fileOutput
    else
        vault::encryptVarsInFile $file $key $cipher $fileOutput ${vars[@]}
    fi
    vault::revertToPlace
    vault::cleanUp
}

vault::decrypt() {
    gFile=$1
    file=$1
    key=$2
    cipher=$3
    gFileOut=$4
    fileOutput=$4
    vars=(${@:5})
    vault::makeTmpCopy
    if [ -z $key ]; then
        key=`vault::getKey`
    fi

    if ! [ -e "$file" ]; then
        echo 'Not exist' 1>&2
        exit 2
    fi
    if [ ${#vars[@]} -eq 1 ] && [ ${vars[0]} == "vault_empty_array" ]; then
        vault::decryptFile $file $key $cipher $fileOutput
    else
        vault::decryptVarsInFile $file $key $cipher $fileOutput ${vars[@]}
    fi
    vault::revertToPlace
    vault::cleanUp
}

vault::ciphers()
{
cat << EOF
Supported ciphers:
aes-128-cbc               aes-128-cfb             aes-128-cfb1
aes-128-cfb8              aes-128-ctr             aes-128-ecb
aes-128-ofb               aes-192-cbc             aes-192-cfb
aes-192-cfb1              aes-192-cfb8            aes-192-ctr
aes-192-ecb               aes-192-ofb             aes-256-cbc
aes-256-cfb               aes-256-cfb1            aes-256-cfb8
aes-256-ctr               aes-256-ecb             aes-256-ofb
aes128                    aes128-wrap             aes192
aes192-wrap               aes256                  aes256-wrap
bf                        bf-cbc                  bf-cfb
bf-ecb                    bf-ofb                  blowfish
camellia-128-cbc          camellia-128-cfb        camellia-128-cfb1
camellia-128-cfb8         camellia-128-ctr        camellia-128-ecb
camellia-128-ofb          camellia-192-cbc        camellia-192-cfb
camellia-192-cfb1         camellia-192-cfb8       camellia-192-ctr
camellia-192-ecb          camellia-192-ofb        camellia-256-cbc
camellia-256-cfb          camellia-256-cfb1       camellia-256-cfb8
camellia-256-ctr          camellia-256-ecb        camellia-256-ofb
camellia128               camellia192             camellia256
cast                      cast-cbc                cast5-cbc
cast5-cfb                 cast5-ecb               cast5-ofb
chacha20                  des                     des-cbc
des-cfb                   des-cfb1                des-cfb8
des-ecb                   des-ede                 des-ede-cbc
des-ede-cfb               des-ede-ecb             des-ede-ofb
des-ede3                  des-ede3-cbc            des-ede3-cfb
des-ede3-cfb1             des-ede3-cfb8           des-ede3-ecb
des-ede3-ofb              des-ofb                 des3
des3-wrap                 desx                    desx-cbc
id-aes128-wrap            id-aes128-wrap-pad      id-aes192-wrap
id-aes192-wrap-pad        id-aes256-wrap          id-aes256-wrap-pad
id-smime-alg-CMS3DESwrap  rc2                     rc2-128
rc2-40                    rc2-40-cbc              rc2-64
rc2-64-cbc                rc2-cbc                 rc2-cfb
rc2-ecb                   rc2-ofb                 rc4
rc4-40                    seed                    seed-cbc
seed-cfb                  seed-ecb                seed-ofb

[usage example]
$ vault -c aes-128-cbc encrypt .envfile
[usage example]
$ vault -c aes-128-cbc -k foobar decrypt .envfile
EOF
}


vault::help() {

cat << EOF
encrypt: vault -e [key] [optional -e [key] -e [key] ] -k [password] -c [optional: cipher (default=aes-256-cbc)] encrypt [in file] [optional: out file]
decrypt: vault decrypt -e [key] [optional -e [key] -e [key] ] -k [password] -c [optional: cipher (default=aes-256-cbc), must match encryption] decrypt [in file] [optional: out file]
ciphers: vault ciphers  - List all ciphers available
-------
[optional: out file] - If not provided original file will be substituted by encrypted | decrypted [in file]
EOF

}

# trap vault::revertAll