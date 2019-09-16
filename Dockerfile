FROM alpine:latest
LABEL Name=docker-mkdocs Version=1.0
LABEL maintainer="Jonathan Sloan"

RUN echo "*** updating system ***" \
    && apk update && apk upgrade \
    && echo "*** installing packages ***" \
    && apk --no-cache add bash git git-fast-import python2 py2-pip shadow \
    && pip2 --no-cache-dir install mkdocs mkdocs-material \
    mkdocs-rtd-dropdown mkdocs-cinder mkdocs-alabaster \
    mkdocs-pitch-dark mkdocs-windmill-dark pygments \
    && echo "*** cleanup ***" \
    && rm -rf /tmp/* /var/tmp/*

VOLUME [ "/docs" ]
CMD ["/bin/bash"]
