FROM alpine:latest AS builder

RUN apk add --no-cache build-base cmake curl openssl-dev libmicrohttpd-dev pkgconfig

WORKDIR /src
COPY X2S/ .

RUN sed -i 's/\bencrypt\b/x2s_encrypt/g; s/\bdecrypt\b/x2s_decrypt/g' \
        src/crypto/encryption.h src/crypto/encryption.c \
        src/cli/migrate.c src/format/format_v2.c src/storage/object_io.c && \
    cmake -S . -B /build && cmake --build /build

FROM alpine:latest

RUN apk add --no-cache libmicrohttpd openssl

LABEL org.opencontainers.image.source=https://github.com/LemmaAlliance/X2S-Docker
LABEL org.opencontainers.image.description="X2S storage server"
LABEL org.opencontainers.image.licenses=GPL-3.0-only

COPY --from=builder /build/x2s /usr/local/bin/x2s
COPY --from=builder /build/x2s-migrate /usr/local/bin/x2s-migrate

EXPOSE 8080

VOLUME /etc/x2s

ENTRYPOINT ["x2s"]
CMD ["--config", "/etc/x2s/config.json"]
