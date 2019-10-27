# docker-mkdocs

![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
[![Build Status](https://dev.azure.com/jsloan117/docker-containers/_apis/build/status/mkdocs?branchName=master)](https://dev.azure.com/jsloan117/docker-containers/_build/latest?definitionId=6&branchName=master)
![Docker Pulls](https://img.shields.io/docker/pulls/jsloan117/docker-mkdocs.svg)
![Microbadger](https://images.microbadger.com/badges/image/jsloan117/docker-mkdocs.svg)

This container contains MkDocs and a handful of themes for quick use. Please see [Run from Docker registry](http://jsloan117.github.io/docker-mkdocs/run-from-docker-registry) for more details and commands.

Mount the folder where your `mkdocs.yml` files resides as a volume to /docs.

``` bash
docker run --rm -it -v ${PWD}:/docs jsloan117/docker-mkdocs mkdocs --version
```

## Documentation

The full documentation is available [here](http://jsloan117.github.io/docker-mkdocs).
