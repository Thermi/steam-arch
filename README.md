# Steam in Docker

Tested in Ubuntu 16.04 LTS (64bit) and openSUSE Leap 42.1
with the following GPU's:

- Intel HD Graphics 3000
- Intel HD Graphics 4400
- NVIDIA's GeForce GTX 560 Ti


## Requirements

- [Docker](https://www.docker.com/)
- (Optional) [Docker Compose](https://docs.docker.com/compose/)


# Building and launching Steam

## Build Steam Docker image

You may want to re-run this command later on in order to keep the image updated.

```
docker build -t andrey01/steam .
```


## Launch the Steam in Docker

You can use the following shortcut function and place it to your `~/.bash_aliases` file

```
function docker_helper() { { pushd ~/docker/$1; docker-compose rm -fa "$1"; docker-compose run -d --name "$1" "$@"; popd; } }
function steam() { { docker_helper $FUNCNAME $@; } }
```

Then just issue "steam" command to run Steam in docker.

## Troubleshooting

You might want to modify the `docker-compose.yml` in case of problems, the file should be pretty self explanatory, although you may refer to the official [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)

Also keep in mind to uncomment or/and add your devices to the `devices:` section there.

The best result is when you have a similar to the following output, using the `glxgears` (part of `mesa-utils` package):

If you are getting `segmentation fault` error or Steam does not start, then you could try resetting its config:

```
$ docker-compose run --rm steam --reset
```

## Grsecurity notes

### grsec: TPE

Trusted Path Execution (TPE)

This Steam docker image is working with the grsecurity patched kernel.
It only needs a `/proc/sys/kernel/grsecurity/tpe_gid` accessible by root for read.


### grsec: PaX

It is also working with PaX part of the grsecurity.  
I have tested it with Half-Life games like CS 1.6, and CS:GO.  
Please refer to the `launch` file if grsecurity is blocking some executable or a library.  


# Links

Below is just bunch of links, someone might find them useful

- https://wiki.ubuntu.com/Valve

- https://developer.valvesoftware.com/wiki/Steam_under_Linux#Ubuntu

- http://media.steampowered.com/client/installer/steam.deb

- http://repo.steampowered.com/steam/archive/precise/steam_latest.deb

- http://repo.steamstatic.com/steam/

- https://grsecurity.net/
