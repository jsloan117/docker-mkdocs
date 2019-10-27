The container is available from the Docker registry and this is the simplest way to get it.
To run the container use one of the following commands:

Get help on commands:

``` bash
docker run --rm -it -v $PWD:/docs jsloan117/docker-mkdocs mkdocs --help
```

Create a new MkDocs project:

``` bash
docker run --rm -it -v $PWD:/docs jsloan117/docker-mkdocs mkdocs new docs
```

Run the builtin development server:

```bash
docker run --rm -it -p 8000:8000 -v $PWD:/docs jsloan117/docker-mkdocs
```

Building MkDocs site:

```bash
docker run --rm -it -v $PWD:/docs jsloan117/docker-mkdocs mkdocs build
```

Publishing to github requires some method to authenticate against GitHub (recommended to use SSH [remote](https://help.github.com/en/github/using-git/changing-a-remotes-url)):

```bash
docker run --rm -it -v $HOME/.ssh:/root/.ssh -v $PWD:/docs jsloan117/docker-mkdocs mkdocs gh-deploy
```
