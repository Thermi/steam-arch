# Debugging

These are some commands I found useful when debugging issues with the Steam games or Steam itself.

They are pretty much unsorted and are intended for an experienced folks.

```
apt-get update && apt-get -y install alsa-utils mesa-utils vim less gdb strace binutils wget
```

```
strings /tmp/dumps/crash_20160429212710_1.dmp |grep -i so$ |awk '{print $NF}' |sort |uniq |grep ^\/ |xargs ldd |grep -i found

for i in $(strings /tmp/dumps/crash_20160429213210_1.dmp |grep -i so$ |awk '{print $NF}' |sort |uniq  |grep -v ^\/ |grep -v ^LD_PRE); do find . -name "$i" | xargs -I@ ldd @ |grep found ;done
```

```
user@6adcb533be2d:~$ diff -u /home/user/.local/share/Steam/steamapps/common/Half-Life/hl.sh.orig /home/user/.local/share/Steam/steamapps/common/Half-Life/hl.sh
--- /home/user/.local/share/Steam/steamapps/common/Half-Life/hl.sh.orig 2016-04-29 21:38:57.725301580 +0200
+++ /home/user/.local/share/Steam/steamapps/common/Half-Life/hl.sh  2016-04-29 21:36:38.155256897 +0200
@@ -1,11 +1,14 @@
 #!/bin/bash
-
+set -x
 # figure out the absolute path to the script being run a bit
 # non-obvious, the ${0%/*} pulls the path out of $0, cd's into the
 # specified directory, then uses $PWD to figure out where that
 # directory lives - and all this in a subshell, so we don't affect
 # $PWD
 
+# export LD_LIBRARY_PATH=/usr/lib/nvidia-340
+echo $LD_LIBRARY_PATH
+
 GAMEROOT=$(cd "${0%/*}" && echo $PWD)
 
 #determine platform
@@ -31,6 +34,8 @@
 # and launch the game
 cd "$GAMEROOT"
 
+DEBUGGER=strace
+
 STATUS=42
 while [ $STATUS -eq 42 ]; do
    ${DEBUGGER} "${GAMEROOT}"/${GAMEEXE} $@
```

The real error was:

```
open("/usr/lib/i386-linux-gnu/libgcrypt.so.11", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
```

```
STEAMLIBS=$(find . -type f -name "*.so" -printf "%f\n" |sort -n |uniq)
find . -type f -name "*.so" -exec ldd '{}' \; |grep 'not found' |sort -n |uniq -c |grep -Ev "echo $STEAMLIBS |tr ' ' '|'"
find . -type f -name "*.so" |xargs -I@ sh -c "ldd '@' | grep -q 'libSteamValidateUserIDTickets_amd64' && echo '@'"
```


----
# Garbage

You are missing the following 32-bit libraries, and Steam may not run:
libc.so.6

```
libgl1-mesa-dri:i386, libgl1-mesa-glx:i386, libc6:i386
```

```
docker run --rm -ti --net bridge -v /tmp/.X11-unix:/tmp/.X11-unix:ro -v /etc/localtime:/etc/localtime:ro -v /etc/machine-id:/etc/machine-id:ro -v $XDG_RUNTIME_DIR/pulse:/run/user/1000/pulse -v /dev/shm:/dev/shm -v steam_data:/home --device /dev/nvidia0 --device /dev/nvidiactl --device /dev/nvidia-uvm --device /dev/nvidia-modeset --device /dev/dri -e DISPLAY=unix$DISPLAY -e PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native --entrypoint bash andrey01/steam
```

```
echo "$(find /usr/lib /usr/lib32 -maxdepth 1 -type d -name "*nvidia*" -print0 |tr '\0' ':' ; echo)"
export LD_LIBRARY_PATH="/usr/lib/nvidia-361:/usr/lib/nvidia-361-prime:/usr/lib/nvidia-340:/usr/lib/nvidia-340-prime:/usr/lib/nvidia-304:/usr/lib32/nvidia-361:/usr/lib32/nvidia-340:/usr/lib32/nvidia-304"

su -p -l -s /bin/bash user -c "steam"
```

```
dpkg --add-architecture i386
apt-get install libgl1-mesa-dri:i386 libgl1-mesa-glx:i386 libc6:i386 mesa-utils:i386

apt-get install libgl1-mesa-dri:i386 libgl1-mesa-glx:i386 libc6:i386

apt-get install libxrender1:i386

export LIBGL_DEBUG=verbose

su -p -l -s /bin/bash user -c "/launch glxdebug"

cp /launch /launch.32
cat /launch.32 |sed 's/linux32//g' > /launch
```

```
$ export LD_LIBRARY_PATH=/usr/lib/nvidia-361:/home/user/.local/share/Steam/ubuntu12_32:/home/user/.local/share/Steam/ubuntu12_32/panorama:/home/user/.local/share/Steam/ubuntu12_32/steam-runtime/i386/usr/lib/i386-linux-gnu
$ export SDL_VIDEO_X11_DGAMOUSE=0
$ /home/user/.local/share/Steam/ubuntu12_32/steam

...
libGL: dlopen /usr/lib/i386-linux-gnu/dri/swrast_dri.so failed (/home/user/.local/share/Steam/ubuntu12_32/steam-runtime/i386/usr/lib/i386-linux-gnu/libstdc++.so.6: version `GLIBCXX_3.4.21' not found (required by /usr/lib/i386-linux-gnu/dri/swrast_dri.so))
...
```

This will install correct swrast_dri.so library that is aware of: ``__driDriverGetExtensions_swrast``

```
# RUN apt-get -y install libgl1-mesa-glx-lts-wily
RUN apt-get -y install libgl1-mesa-dri-lts-wily libgl1-mesa-glx-lts-wily
RUN apt-get -y install libgl1-mesa-dri-lts-wily:i386 libgl1-mesa-glx-lts-wily:i386
```

This will install correct swrast_dri.so library that is aware of: ``__driDriverGetExtensions_swrast``

```
# RUN apt-get -y install libgl1-mesa-glx-lts-utopic:i386
# RUN apt-get -y install libgl1-mesa-glx-lts-wily:i386
RUN apt-get -y install libgl1-mesa-dri-lts-wily:i386 libgl1-mesa-glx-lts-wily:i386
# Try ? xserver-xorg-lts-wily:i386
```
