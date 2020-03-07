# docker-mkdocs

![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
[![Build Status](https://travis-ci.com/jsloan117/docker-mkdocs.svg?branch=master)](https://travis-ci.com/jsloan117/docker-mkdocs)
![Docker Pulls](https://img.shields.io/docker/pulls/jsloan117/docker-mkdocs.svg)

This container contains MkDocs and a handful of themes for quick use. Please see [Run from Docker registry](http://jsloan117.github.io/docker-mkdocs/run-from-docker-registry) for more details and commands.

Mount the folder where your `mkdocs.yml` files reside as a volume to /docs.

``` bash
docker run --rm -it -v ${PWD}:/docs jsloan117/docker-mkdocs mkdocs --version
```

## Documentation

The full documentation is available [here](http://jsloan117.github.io/docker-mkdocs).
