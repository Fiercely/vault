#### Test Description

The tests decribed here are to be used on a jenkins pipeline, that makes use of vault as a tool.

The tests have full file encryption and var encryption.

Both expected output files were encrypted with `foo` as a password from the unencrypted files.

Example to obtain vault decrypted full.expected.txt

```sh
vault -k foo decrypt full.expected.txt full.decrypted.txt
```

Example to obtain vault decrypted vars.expected.txt

```sh
vault -k foo -e MADE -e AUTHOR -e URL -e COMPANY decrypt vars.expected.txt vars.decrypted.txt
```

Example to obtain partially decrypted vars.expected.txt

```sh
vault -k foo -e AUTHOR --e COMPANY decrypt vars.expected.txt vars.decrypted.txt
```

To know how to setup your own tests, check `ci` folder which contains the Container to create the jenkins instance ready to test this repository.