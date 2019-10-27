<h1 align="center">
  docker-mkdocs
</h1>

<p align="center">
  MkDocs and a handful of themes for quick use
  <br/><br/>

  <a href="https://github.com/jsloan117/docker-mkdocs/blob/master/LICENSE/">
    <img alt="license" src="https://img.shields.io/badge/License-GPLv3-blue.svg" />
  </a>
  <a href="https://dev.azure.com/jsloan117/docker-containers/_build?definitionId=6">
    <img alt="build" src="https://dev.azure.com/jsloan117/docker-containers/_apis/build/status/mkdocs?branchName=master" />
  </a>
  <a href="https://hub.docker.com/r/jsloan117/docker-mkdocs/">
    <img alt="pulls" src="https://img.shields.io/docker/pulls/jsloan117/docker-mkdocs.svg" />
  </a>
  <a href="https://microbadger.com/images/jsloan117/docker-mkdocs">
    <img alt="Microbadger" src="https://images.microbadger.com/badges/image/jsloan117/docker-mkdocs.svg" />
  </a>
</p>

This container contains MkDocs and a handful of themes for quick use. Please see [Run from Docker registry](http://jsloan117.github.io/docker-mkdocs/run-from-docker-registry) for more details and commands.

Mount the folder where your `mkdocs.yml` files resides as a volume to /docs.

``` bash
docker run --rm -it -v ${PWD}:/docs jsloan117/docker-mkdocs mkdocs --version
```
