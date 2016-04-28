FROM andrey01/xenial32
MAINTAINER Andrey Arapov <andrey.arapov@nixaid.com>

# To avoid problems with Dialog and curses wizards
ENV DEBIAN_FRONTEND noninteractive

#
# Prepare the image
#
# ----------------------------------------------------------------------------
# TODO: move the following workarounds directly into the xenial32 image !
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial main restricted" > /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ xenial-updates main restricted" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ xenial-security main restricted" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ xenial universe" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ xenial-updates universe" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ xenial-security universe" >> /etc/apt/sources.list

# Workaround to xenial32's following error:
#     initctl: Unable to connect to Upstart: Failed to connect to socket /com/ubuntu/upstart: Connection refused
RUN dpkg-divert --local --rename --add /sbin/initctl && \
    ln -s /bin/true /sbin/initctl

# Prevent the services from automatically being started after they have been installed
RUN echo -e '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d
# ----------------------------------------------------------------------------


# 1. Keep the image updated
# 2. Install the dependencies
# 3. Install the latest version of Steam
# http://repo.steampowered.com/steam
RUN echo "deb [arch=amd64,i386] http://repo.steampowered.com/steam/ precise steam" > /etc/apt/sources.list.d/tmp-steam.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0xF24AEA9FB05498B7 && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    apt-get -fy install && \
    apt-get -y install binutils pciutils pulseaudio mesa-utils steam && \
    rm -f /etc/apt/sources.list.d/tmp-steam.list && \
    rm -rf /var/lib/apt/lists

# COPY [ "nvidia-340-mini", "/usr/lib/nvidia-340" ]

# Install NVIDIA Drivers.
# Currently supported versions: 304, 340, 361
ADD http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-304/nvidia-304_304.131-0ubuntu3_i386.deb /tmp/nvidia-304.deb
ADD http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-340/nvidia-340_340.96-0ubuntu3_i386.deb /tmp/nvidia-340.deb
ADD http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-361/nvidia-361_361.42-0ubuntu2_i386.deb /tmp/nvidia-361.deb

RUN cd /tmp && \
    ar xv nvidia-304.deb data.tar.xz && \
    tar xf data.tar.xz -C / && \
    rm -f data.tar.xz nvidia-304.deb

RUN cd /tmp && \
    ar xv nvidia-340.deb data.tar.xz && \
    tar xf data.tar.xz -C / && \
    rm -f data.tar.xz nvidia-340.deb

RUN cd /tmp && \
    ar xv nvidia-361.deb data.tar.xz && \
    tar xf data.tar.xz -C / && \
    rm -f data.tar.xz nvidia-361.deb


# Set the locale to en_US.UTF-8
RUN locale-gen en_US.UTF-8 && \
    update-locale

# Workaround missing lib in .local/share/Steam/ubuntu12_32/steamclient.so
RUN ln -sv /lib/i386-linux-gnu/libudev.so.1 /lib/i386-linux-gnu/libudev.so.0

# Workaround: pulseaudio client library eager to remove /dev/shm/pulse-shm-* files created by the host,
#             causing sound to stop working
RUN echo "enable-shm = no" >> /etc/pulse/client.conf

# Create a user
ENV USER user
ENV UID 1000
ENV GROUPS audio,video
ENV HOME /home/$USER
RUN useradd -m -d $HOME -u $UID -G $GROUPS $USER

USER $USER
WORKDIR $HOME
COPY ./launch /launch
ENTRYPOINT [ "/launch" ]
