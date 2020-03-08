FROM alpine:3.11
LABEL Name=mkdocs maintainer="Jonathan Sloan"

RUN echo "*** installing packages ***" \
    && apk --no-cache add git git-fast-import openssh-client python3 \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py' \
    && python3 get-pip.py --disable-pip-version-check --no-cache-dir \
    && rm -f get-pip.py \
    && pip --no-cache-dir install mkdocs mkdocs-material \
    mkdocs-rtd-dropdown mkdocs-cinder mkdocs-alabaster \
    mkdocs-pitch-dark mkdocs-windmill-dark pygments \
    && git config --global user.name MkDocs \
    && echo "*** cleanup ***" \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

WORKDIR /docs

VOLUME [ "/docs" ]

ENTRYPOINT [ "mkdocs" ]
CMD [ "--help" ]
