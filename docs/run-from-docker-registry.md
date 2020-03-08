The container is available from the Docker registry and this is the simplest way to get it.
To run the container use one of the following commands:

Get help on commands:

``` bash
docker run --rm -v $PWD:/docs jsloan117/mkdocs
```

Create a new MkDocs project:

``` bash
docker run --rm -v $PWD:/docs jsloan117/mkdocs new docs
```

Run the builtin development server:

```bash
docker run --rm -p 8000:8000 -v $PWD:/docs jsloan117/mkdocs serve -a 0.0.0.0:8000
```

Building MkDocs site:

```bash
docker run --rm -v $PWD:/docs jsloan117/mkdocs build
```

Publishing to github requires some method to authenticate against GitHub (recommended to use SSH [remote](https://help.github.com/en/github/using-git/changing-a-remotes-url)):

```bash
docker run --rm -v $HOME/.ssh:/root/.ssh -v $PWD:/docs jsloan117/mkdocs gh-deploy
```
