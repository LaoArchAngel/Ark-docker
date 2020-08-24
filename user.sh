#!/bin/sh

# Change the ARK_UID if needed
if [ ! "$(id -u steam)" -eq "$ARK_UID" ]; then 
	echo "Changing steam uid to $ARK_UID."
	usermod -o -u "$ARK_UID" steam ; 
fi
# Change gid if needed
if [ ! "$(id -g steam)" -eq "$ARK_GID" ]; then 
	echo "Changing steam gid to $ARK_GID."
	groupmod -o -g "$ARK_GID" steam ; 
fi

# Set Timezone
if [ -f /usr/share/zoneinfo/"${TZ}" ]; then
    echo "Setting timezone to '${TZ}'..."
    ln -sf /usr/share/zoneinfo/"${TZ}" /etc/localtime
else
    echo "Timezone '${TZ}' does not exist!"
fi

# Put steam owner of directories (if the uid changed, then it's needed)
chown -R steam:steam /ark /home/steam

# avoid error message when su -p (we need to read the /root/.bash_rc )
chmod -R 777 /root/

rm -Rf /etc/arkmanager/instances
ln -sf /ark/config/instances /etc/arkmanager/instances

# Starting cron
# If there is uncommented line in the file
CRONNUMBER=$(grep -v "^#" /ark/config/crontab | wc -l)
if [ $CRONNUMBER -gt 0 ]; then
	echo "Loading crontab..."
	# We load the crontab file if it exist.
	# crontab /ark/crontab
	# Cron is attached to this process
	sudo crond -np &
else
	echo "No crontab set."
fi

# Launch run.sh with user steam
su -p -c /home/steam/run.sh steam
