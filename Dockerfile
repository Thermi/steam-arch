FROM debian:jessie
MAINTAINER Andrey Arapov <andrey.arapov@nixaid.com>

# To avoid problems with Dialog and curses wizards
ENV DEBIAN_FRONTEND noninteractive

# 1. Keep the image updated
# 2. Install the dependencies
# 3. Install the latest version of Steam
# http://repo.steampowered.com/steam
RUN echo "deb [arch=amd64,i386] http://repo.steampowered.com/steam/ precise steam" > /etc/apt/sources.list.d/tmp-steam.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0xF24AEA9FB05498B7 && \
    dpkg --add-architecture i386 && \
    apt-get clean && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    apt-get -fy install && \
    apt-get -y install binutils pciutils pulseaudio libcanberra-gtk-module \
                       libopenal1 libnss3 libgconf-2-4 libxss1 libnm-glib4 \
                       libnm-util2 libglu1-mesa locales \
                       steam-launcher \
                       mesa-utils:i386 \
                       libstdc++5 libstdc++5:i386 libbz2-1.0:i386 \
                       libavformat56 libswscale3 libavcodec56:i386 \
                       libavformat56:i386 libavresample2:i386 libavutil54:i386 \
                       libswscale3:i386 libsdl2-2.0-0 libsdl2-2.0-0:i386 \
                       libgl1-mesa-dri:i386 libgl1-mesa-glx:i386 libc6:i386 \
                       libxtst6:i386 libxrandr2:i386 libglib2.0-0:i386 \
                       libgtk2.0-0:i386 libgdk-pixbuf2.0-0:i386 libsm6:i386 \
                       libice6:i386 libopenal1:i386 libdbus-glib-1-2:i386 \
                       libnm-glib4:i386 libnm-util2:i386 libusb-1.0-0:i386 \
                       libnss3:i386 libgconf-2-4:i386 libxss1:i386 libcurl3:i386 \
                       libv8-dev:i386 \
                       libcanberra-gtk-module:i386 libpulse0:i386 attr && \
    rm -f /etc/apt/sources.list.d/tmp-steam.list && \
    rm -rf /var/lib/apt/lists

# Not sure whether we really need these:
# libcurl3 libcanberra-gtk-module

# Workaround missing lib in .local/share/Steam/ubuntu12_32/steamclient.so
RUN ln -sv libudev.so.1 /lib/i386-linux-gnu/libudev.so.0

# Workaround: Ubuntu 16.04 doesn't have libgcrypt11, so we take it from trusty
# Required by Half-Life based games
# TODO: use debian mirrors if possible?
ADD http://archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4_i386.deb /tmp/libgcrypt11_i386.deb
ADD http://archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4_amd64.deb /tmp/libgcrypt11_amd64.deb
RUN cd /tmp && \
    dpkg -i libgcrypt11_*.deb && \
    rm -f libgcrypt11_*.deb


# locale-gen: Generate locales based on /etc/locale.gen file
# update-locale: Generate config /etc/default/locale (later read by /etc/pam.d/su, /etc/pam.d/login, /etc/pam.d/polkit-1)
RUN sed -i.orig '/^# en_US.UTF-8.*/s/^#.//g' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Create a user
ENV USER user
ENV UID 1000
ENV GROUPS audio,video
ENV HOME /home/$USER
RUN useradd -m -d $HOME -u $UID -G $GROUPS $USER

WORKDIR $HOME

ENV STEAM_RUNTIME 0

COPY ./launch /launch
ENTRYPOINT [ "/bin/bash", "/launch" ]
