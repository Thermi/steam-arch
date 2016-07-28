# Steam in Docker

Tested in Ubuntu 16.04 LTS (64bit) with the following GPU's:

- Intel HD Graphics 3000
- Intel HD Graphics 4400
- NVIDIA's GeForce GTX 560 Ti


## Requirements

- [Docker](https://www.docker.com/)
- (Optional) [Docker Compose](https://docs.docker.com/compose/)

## Limitations

- The version of your Nvidia drivers should match the ones in Dockerfile used to build this image


## Known issues

- Steam is working only with the 32-bit Nvidia drivers

- CS:GO (csgo_linux64) is working only with the 64-bit Nvidia drivers

To run CS:GO, you will need to download and extract the 64-bit Nvidia drivers while Steam is running:

```
docker exec -ti steam bash
root@steam-container:~# curl -o /tmp/nvidia-361.deb http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-361/nvidia-361_361.42-0ubuntu2_amd64.deb
root@steam-container:~# cd /tmp && ar xv nvidia-361.deb data.tar.xz && tar xf data.tar.xz -C / && rm -f data.tar.xz nvidia-361.deb
```


## Notes

- I have added the `/launch` script that will try to detect the working version of the NVIDIA drivers.
   Currently this image supports these versions of the NVIDIA driver: 304, 340, 361.
   It will fallback to the Generic OpenGL driver in case of failure.

- Do not forget to pass host device `/dev/nvidia-modeset` to a container when running with NVIDIA driver >= 361.


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

```
$ docker-compose run --rm steam glxdebug
Attempting to load one of the supported NVIDIA drivers:
    Trying to load NVIDIA driver version: 361 ... FAILURE
    Trying to load NVIDIA driver version: 340 ... SUCCESS
LD_LIBRARY_PATH is set to: /usr/lib/nvidia-340
Running synchronized to the vertical refresh.  The framerate should be
approximately the same as the monitor refresh rate.
GL_RENDERER   = GeForce GTX 560 Ti/PCIe/SSE2
GL_VERSION    = 4.4.0 NVIDIA 340.96
GL_VENDOR     = NVIDIA Corporation
GL_EXTENSIONS = GL_AMD_multi_draw_indirect GL_ARB_arrays_of_arrays ...
...
305 frames in 5.0 seconds = 60.878 FPS
301 frames in 5.0 seconds = 60.011 FPS
301 frames in 5.0 seconds = 60.009 FPS
305 frames in 5.0 seconds = 60.807 FPS
```

If you are getting `segmentation fault` error or Steam does not start, then you could try resetting its config:

```
$ docker-compose run --rm steam --reset
```

# Links

Below is just bunch of links, someone might find them useful

- https://wiki.ubuntu.com/Valve

- https://developer.valvesoftware.com/wiki/Steam_under_Linux#Ubuntu

- http://media.steampowered.com/client/installer/steam.deb

- http://repo.steampowered.com/steam/archive/precise/steam_latest.deb

- http://repo.steamstatic.com/steam/
