# Steam in Docker

Tested in Ubuntu 16.04 LTS (64bit) with the following GPU's:

- Intel HD Graphics 3000
- Intel HD Graphics 4400
- NVIDIA's GeForce GTX 560 Ti


## Requirements

- [Docker](https://www.docker.com/)
- (Optional) [Docker Compose](https://docs.docker.com/compose/)


# Building and launching Steam

## Create 32bit image

Create 32-bit Ubuntu 16.04 LTS (xenial) image

```
sudo apt-get -y install debootstrap
sudo debootstrap --arch=i386 xenial /tmp/xenial-chroot http://archive.ubuntu.com/ubuntu
sudo tar -C /tmp/xenial-chroot -c . | docker import - xenial32
sudo rm -rf /tmp/xenial-chroot
docker tag xenial32 andrey01/xenial32:latest
```

## Build Steam Docker image

You may want to re-run this command later on in order to keep the image updated.

```
docker build -t andrey01/steam .
```


## Launch the Steam in Docker

You can drop the following aliases to your ~/.bash_aliases

```
alias docker="sudo docker"
alias docker-compose="sudo docker-compose"
alias steam="docker-compose -f $HOME/docker/steam/docker-compose.yml run --rm steam"
```

Then just issue "steam" command to run Steam in docker.

## Troubleshooting

You might want to modify the `docker-compose.yml` in case of problems, the file should be pretty self explanatory, although you may refer to the official [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)

Also keep in mind to uncomment or/and add your devices to the `devices:` section there.

The best result is when you have a similar to the following output, using the `glxgears` (part of `mesa-utils` package):

```
$ docker-compose -f $HOME/docker/steam/docker-compose.yml run --rm --entrypoint glxgears steam
Running synchronized to the vertical refresh.  The framerate should be
approximately the same as the monitor refresh rate.
305 frames in 5.0 seconds = 60.878 FPS
301 frames in 5.0 seconds = 60.011 FPS
301 frames in 5.0 seconds = 60.009 FPS
305 frames in 5.0 seconds = 60.807 FPS
```

If you are getting `segmentation fault` error or Steam does not start, then you could try resetting its config:

```
$ docker-compose -f $HOME/docker/steam/docker-compose.yml run --rm steam --reset
```

# Links

Below is just bunch of links, someone might find them useful

- https://wiki.ubuntu.com/Valve

- https://developer.valvesoftware.com/wiki/Steam_under_Linux#Ubuntu

- http://media.steampowered.com/client/installer/steam.deb

- http://repo.steampowered.com/steam/archive/precise/steam_latest.deb

- http://repo.steamstatic.com/steam/
