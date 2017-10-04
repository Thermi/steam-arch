# Steam in Docker

## Why?

Some people asked me why would someone want to have Steam in a Docker container?
Few main points which pushed me making this Docker container:

1. I want to set-up more fences when running the code I don't/can't trust; [issue 3671](https://github.com/valvesoftware/steam-for-linux/issues/3671)
2. I don't want to spend time on figuring out how to install Steam (what deps) in a non-Debian (or non-SteamOS) based distro;
3. I like cleanliness: I can erase Steam and all its dependencies in a matter of seconds;

And few Pros from my PoV:

- I can have Steam on my Ubuntu/openSUSE/[put any other distro I will want to use] in a short time that Docker takes when downloads this Steam container;
- Since Steam is meant to run in Debian (SteamOS) based distro, it is not a problem anymore, since it is in a container now.

Suggestions / PR's are welcomed!

## What's tested?

The following games have been tested:

- Counter-Strike: Global Offensive
- Alien: Isolation
- PAYDAY 2
- Insurgency
- Half-Life: Counter-Strike 1.6
- Iron Snout
- Toribash
- DeadCore (no sound)

Tested in Ubuntu 16.04 LTS (64bit) and openSUSE Leap 42.1
with the following GPU's:

- Intel HD Graphics 3000
- Intel HD Graphics 4400
- NVIDIA's GeForce GTX 560 Ti

## Requirements

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/) minimum version 1.7.3

# Building and launching Steam

## Launching Steam in Docker

The simplest way to launch Steam is by running:

```sh
git clone https://github.com/arno01/steam.git
cd steam
docker-compose run steam
```

If Steam does not start, you may need to allow your user making local
connections to X server, which can be achieved with this command on host:

```sh
xhost +SI:localuser:$(id -un)
```

You can use the following shortcut function and place it to your `~/.bash_aliases` file:

```sh
function docker_helper() {
    pushd ~/docker/$1
    docker-compose rm -fa "$1"
    docker-compose run -d --name "$1" "$@"
    popd
}

function steam() {
    docker_helper "$FUNCNAME" "$@"
}
```

Then just use `steam` command to run Steam in docker.

## Updating Steam Docker image

You may want to re-run this command later on in order to keep the image updated:

```sh
VERSION=$(git rev-parse HEAD | head -c8) make
```

## Troubleshooting

You might want to modify the `docker-compose.yml` in case of problems, the file should be pretty self explanatory, although you may refer to the official [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)

Also keep in mind to uncomment or/and add your devices to the `devices:` section there.

The best result is when you have a similar to the following output, using the `glxgears` (part of `mesa-utils` package):

If you are getting `segmentation fault` error or Steam does not start, then you could try resetting its config:

```sh
docker-compose run --rm steam --reset
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
