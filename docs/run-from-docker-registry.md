The container is available from the Docker registry and this is the simplest way to get it.
To run the container use this command:

``` bash
docker run --rm -it -v $PWD:/docs jsloan117/docker-mkdocs mkdocs new docs
```

Serving mkdocs site the IPs and ports can change as you need.

```bash
docker run --rm -it -p 4040:4040 -v $PWD:/docs jsloan117/docker-mkdocs /bin/bash -c "cd /docs && mkdocs serve -a 0.0.0.0:4040"
```

Building mkdocs site

```bash
docker run --rm -it -v $PWD:/docs jsloan117/docker-mkdocs /bin/bash -c "cd /docs && mkdocs build"
```

Publishing to github pages

```bash
docker run --rm -it -v $PWD:/docs jsloan117/docker-mkdocs /bin/bash -c "cd /docs && mkdocs gh-deploy"
```
