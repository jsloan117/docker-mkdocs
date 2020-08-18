FROM alpine:3.12
LABEL Name=mkdocs Maintainer="Jonathan Sloan"

RUN echo "*** installing packages ***" \
    && apk --no-cache add git git-fast-import openssh-client python3 python3-dev py3-pip py3-wheel gcc musl-dev \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && pip3 --no-cache-dir install mkdocs mkdocs-material \
    mkdocs-rtd-dropdown mkdocs-cinder mkdocs-alabaster \
    mkdocs-pitch-dark mkdocs-windmill-dark pygments pymdown-extensions \
    && apk del python3-dev gcc musl-dev \
    && git config --global user.name MkDocs \
    && echo "*** cleanup ***" \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/lib/apk/*

WORKDIR /docs

VOLUME [ "/docs" ]

COPY VERSION .

ENTRYPOINT [ "mkdocs" ]
CMD [ "--help" ]
