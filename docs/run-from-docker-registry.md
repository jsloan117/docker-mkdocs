The container is available from the Docker registry and this is the simplest way to get it.
To run the container use this command:

``` bash
docker run --rm -it -v $PWD:/docs jsloan117/docker-mkdocs mkdocs new docs
```

Serving mkdocs site

```bash
docker run --rm -it -v $PWD:/docs jsloan117/docker-mkdocs /bin/bash -c "cd /docs && mkdocs serve"
```

Building mkdocs site

```bash
docker run --rm -it -v $PWD:/docs jsloan117/docker-mkdocs /bin/bash -c "cd /docs && mkdocs build"
```
