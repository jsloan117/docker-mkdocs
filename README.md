# docker-mkdocs

![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
[![Build Status](https://travis-ci.com/jsloan117/docker-mkdocs.svg?branch=master)](https://travis-ci.com/jsloan117/docker-mkdocs)
![Docker Pulls](https://img.shields.io/docker/pulls/jsloan117/mkdocs.svg)

This container contains MkDocs and a handful of themes for quick use. Please see [Run from Docker registry](http://jsloan117.github.io/mkdocs/run-from-docker-registry) for more details and commands.

Mount the folder where your `mkdocs.yml` file resides as a volume to /docs.

``` bash
docker run --rm -v ${PWD}:/docs jsloan117/mkdocs --version
```

## Documentation

The full documentation is available [here](http://jsloan117.github.io/mkdocs).
