#!/usr/bin/env bash
echo "###########################################################################"
echo "# Ark Server - " `date`
echo "# UID $ARK_UID - GID $ARK_GID"
echo "###########################################################################"
[ -p /tmp/FIFO ] && rm /tmp/FIFO
mkfifo /tmp/FIFO

export TERM=linux

function stop {
	if [ ${BACKUPONSTOP} -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks)" ]; then
		echo "[Backup on stop]"
		arkmanager backup
	fi
	if [ ${WARNONSTOP} -eq 1 ];then 
	    arkmanager stop --warn
	else
	    arkmanager stop
	fi
	exit
}

# Change working directory to /ark to allow relative path
cd /ark

# Add a template directory to store the last version of config file
[ ! -d /ark/template ] && mkdir /ark/template
# We overwrite the template file each time
cp /home/steam/arkmanager.cfg /ark/template/arkmanager.cfg
cp /home/steam/crontab /ark/template/crontab
# Creating directory tree && symbolic link
[ ! -f /ark/config/arkmanager.cfg ] && cp /home/steam/arkmanager.cfg /ark/config/arkmanager.cfg
[ ! -d /ark/log ] && mkdir /ark/log
[ ! -d /ark/backup ] && mkdir /ark/backup
[ ! -d /ark/staging ] && mkdir /ark/staging

[ ! -f /ark/config/Game.ini ] && [ -f server/ShooterGame/Saved/Config/LinuxServer/Game.ini ] && cp server/ShooterGame/Saved/Config/LinuxServer/Game.ini /ark/config/Game.ini
[ ! -f /ark/config/GameUserSettings.ini ] && [ -f server/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini ]  && cp server/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini /ark/config/GameUserSettings.ini
[ ! -f /ark/config/crontab ] && cp /ark/template/crontab /ark/config/crontab

if [ ! -d /ark/server  ] || [ ! -f /ark/server/PackageInfo.bin ];then
	echo "No game files found. Installing..."
	mkdir -p /ark/server/ShooterGame/Saved/SavedArks
	mkdir -p /ark/server/ShooterGame/Content/Mods
	mkdir -p /ark/server/ShooterGame/Binaries/Linux/
	touch /ark/server/ShooterGame/Binaries/Linux/ShooterGameServer
	arkmanager install
	# Create mod dir
else
	if [ ${BACKUPONSTART} -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks/)" ]; then
		echo "[Backup]"
		arkmanager backup
	fi
fi

#copying the actual configs
echo "Copying the config files..."
[ -f /ark/config/Game.ini ] && cp /ark/config/Game.ini server/ShooterGame/Saved/Config/LinuxServer/Game.ini
[ -f /ark/config/GameUserSettings.ini ] && cp /ark/config/GameUserSettings.ini server/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini


# Launching ark server
if [ $UPDATEONSTART -eq 0 ]; then
	arkmanager start --noautoupdate
else
	arkmanager start
fi


# Installing crontab for user steam
echo "Loading crontab..."
#cat /ark/crontab | crontab -
crontab /ark/config/crontab


# Stop server in case of signal INT or TERM
echo "Server Finished Loading!  Waiting for stop..."
trap stop INT
trap stop TERM

read < /tmp/FIFO &
wait

arkmanager stop @all --saveworld
