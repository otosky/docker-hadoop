## Intermediary Layer to Download and Verify Apache Tarballs
FROM alpine

RUN mkdir -p /usr/share/man/man1
RUN apk update && apk add \
    tar \
    ca-certificates \
    curl \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://dist.apache.org/repos/dist/release/hadoop/common/KEYS

RUN gpg --import KEYS

ENV APACHE_URL_PREFIX https://www.apache.org/dyn/closer.cgi?action=download&filename=
