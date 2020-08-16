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

RUN systemctl enable dnsmasq

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


# Copy update scripts
COPY arkupdate /usr/local/bin
COPY arkmodupdate /usr/local/bin

RUN chmod +x /usr/local/bin/arkupdate \
 && chmod +x /usr/local/bin/arkmodupdate


# Copy & rights to folders
COPY crontab /home/steam/crontab
COPY arkmanager-user.cfg /home/steam/arkmanager.cfg
COPY instance.cfg /home/steam/instance.cfg

RUN mkdir /ark \
 && mkdir /ark/instances \
 && mkdir -p /home/steam/Steam/steamapps/workshop \
 && chown steam /ark && chmod 755 /ark \
 && chown -R steam:steam /home/steam

# Define default config file in /etc/arkmanager
COPY arkmanager-system.cfg /etc/arkmanager/arkmanager.cfg

VOLUME /ark/config
VOLUME /ark/saves
VOLUME /ark/backup
VOLUME /ark/log


# Change the working directory to /ark
WORKDIR /ark


## Startup Scripts ##
COPY run.sh /home/steam/run.sh
COPY user.sh /home/steam/user.sh
COPY --chown=steam:steam ark-create-all-shallows.sh ark-create-shallow.sh ark-gen-shallow.sh ark-set-shallow-save.sh check-shallow-ark.sh /home/steam/

RUN chmod +x /home/steam/ark-create-all-shallows.sh /home/steam/ark-create-shallow.sh /home/steam/ark-gen-shallow.sh /home/steam/ark-set-shallow-save.sh /home/steam/check-shallow-ark.sh
RUN ln -s /home/steam/ark-create-all-shallows.sh /usr/local/bin/ark-create-all-shallows \
  ln -s /home/steam/ark-create-shallow.sh /usr/local/bin/ark-create-shallow \
  ln -s /home/steam/ark-gen-shallow.sh /usr/local/bin/ark-gen-shallow \
  ln -s /home/steam/ark-set-shallow-save.sh  /usr/local/bin/ark-set-shallow-save \
  ln -s /home/steam/check-shallow-ark.sh  /usr/local/bin/check-shallow-ark

RUN chmod 777 /home/steam/run.sh \
 && chmod 777 /home/steam/user.sh


# Update game launch the game.
ENTRYPOINT ["/home/steam/user.sh"]
