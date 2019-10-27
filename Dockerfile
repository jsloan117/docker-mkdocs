FROM alpine:latest
LABEL Name=docker-mkdocs Version=1.2
LABEL maintainer="Jonathan Sloan"

RUN echo "*** updating system ***" \
    && apk update && apk --no-cache upgrade \
    && echo "*** installing packages ***" \
    && apk --no-cache add bash git git-fast-import openssh-client python3 shadow \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; python3 get-pip.py --disable-pip-version-check --no-cache-dir \
    && pip --no-cache-dir install mkdocs mkdocs-material \
    mkdocs-rtd-dropdown mkdocs-cinder mkdocs-alabaster \
    mkdocs-pitch-dark mkdocs-windmill-dark pygments \
    && git config --global user.name MkDocs \
    && echo "*** cleanup ***" \
    && rm -rf /tmp/* /var/tmp/*

WORKDIR /docs

VOLUME [ "/docs" ]

CMD [ "mkdocs", "serve", "-a", "0.0.0.0:8000" ]
