## Taste Dockerfile


This repository contains **Dockerfile** of [Taste](http://taste.tuxfamily.org/wiki/index.php?title=Main_Page) for
[Docker](https://www.docker.com/)'s [automated
build](https://registry.hub.docker.com/u/exoter/taste/) published to the
public [Docker Hub Registry](https://registry.hub.docker.com/).


### Base Docker Image

* [ubuntu:14.04](https://hub.docker.com/r/i386/ubuntu/)


### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/exoter/taste/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull exoter/taste

   (alternatively, you can build an image from Dockerfile: `docker build github.com/exoter-rover/docker-taste`-t exoter/taste .)


### Usage

    docker run -it --rm exoter/taste:14.04

    You can also use the script file docker-taste-create.sh as following

