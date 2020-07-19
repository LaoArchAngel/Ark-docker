FROM centos:latest

# Var for first config
ENV SERVERPASSWORD="" \
    ADMINPASSWORD="adminpassword" \
    MAX_PLAYERS=70 \
    BACKUPONSTART=1 \
    BACKUPONSTOP=1 \
    WARNONSTOP=1 \
    ARK_UID=1000 \
    ARK_GID=1000 \
    TZ=UTC

## Install dependencies
RUN dnf clean packages
RUN dnf -y install glibc.i686 libstdc++.i686 git lsof bzip2 cronie perl-Compress-Zlib curl bash findutils perl rsync sed tar sudo dnsmasq gettext \
 && dnf clean all


## Prepare steam user
RUN adduser -u $ARK_UID -s /bin/bash -U steam
 
RUN usermod -a -G wheel steam

## Always get the latest version of ark-server-tools
RUN curl -sL http://git.io/vtf5N | sudo bash -s steam
RUN (crontab -l 2>/dev/null; echo "* 3 * * Mon yes | /usr/local/bin/arkmanager upgrade-tools >> /ark/log/arkmanager-upgrade.log 2>&1") | crontab -


## Install SteamCmd ##
RUN mkdir /home/steam/steamcmd \
  && cd /home/steam/steamcmd \
  && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -


# Copy & rights to folders
COPY crontab /home/steam/crontab
COPY arkmanager-user.cfg /home/steam/arkmanager.cfg

RUN mkdir /ark \
 && chown steam /ark && chmod 755 /ark

# Define default config file in /etc/arkmanager
COPY arkmanager-system.cfg /etc/arkmanager/arkmanager.cfg

# Define default config file in /etc/arkmanager
COPY instance.cfg /etc/arkmanager/instances/main.cfg

VOLUME /ark/config
VOLUME /ark/server/install/ShooterGame/Saved
VOLUME /ark/backup
VOLUME /ark/log


# Change the working directory to /ark
WORKDIR /ark


## Startup Scripts ##
COPY run.sh /home/steam/run.sh
COPY user.sh /home/steam/user.sh

RUN chmod 777 /home/steam/run.sh \
 && chmod 777 /home/steam/user.sh


# Update game launch the game.
ENTRYPOINT ["/home/steam/user.sh"]
