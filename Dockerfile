FROM alpine:3.8
RUN apk --update add bash openssl
COPY bin/vault /usr/bin/vault
COPY src/vault.sh /usr/src/vault.sh
ENTRYPOINT [ "vault" ]