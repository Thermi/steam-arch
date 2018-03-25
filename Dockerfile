# On the basis of the debian steam container by Andrey Arapov <andrey.arapov@nixaid.com>
FROM archimg/base
MAINTAINER Noel Kuntze <noel@familie-kuntze.de>

# To avoid problems with Dialog and curses wizards
ENV DEBIAN_FRONTEND noninteractive

# 1. Keep the image updated
# 2. Install the dependencies
# 3. Install the latest version of Steam
# http://repo.steampowered.com/steam

RUN sed -i.orig '/^# de_DE.UTF-8.*/s/^#.//g' /etc/locale.gen && \
    locale-gen

RUN cat /etc/resolv.conf

RUN sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/#//' /etc/pacman.conf && \
    dirmngr </dev/null > /dev/null 2>&1 && \
    sed -i "s/#Color/Color/" /etc/pacman.conf && \
    pacman --noconfirm -Syu archlinux-keyring && pacman --noconfirm -S steam && \
    rm -rf /usr/share/info/* && \
    rm -rf /usr/share/man/* && \
    rm -rf /usr/share/doc/*

RUN # was a bit worried about these at first but I haven't seen an issue yet on them. \
    rm -rf /usr/share/zoneinfo/* && \
    rm -rf /usr/share/i18n/*

RUN # Delete any backup files like /etc/pacman.d/gnupg/pubring.gpg~ \
    find /. -name "*~" -type f -delete && \
    # Keep only xterm related profiles in terminfo.
    find /usr/share/terminfo/. ! -name "*xterm*" ! -name "*screen*" ! -name "*screen*" -type f -delete && \
RUN bash -c "echo 'y' | pacman -Scc >/dev/null 2>&1" && \
    paccache -rk0 >/dev/null 2>&1 &&  \
    pacman-optimize && \
    pacman -Runs --noconfirm tar && \
    rm -rf /var/lib/pacman/sync/*

RUN rm -rf /tmp/*

ENV LANG de_DE.UTF-8
ENV LC_ALL de_DE.UTF-8

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
