#!/usr/bin/env bash

echo "###########################################################################"
echo "# Ark Server - $(date)"
echo "# UID $ARK_UID - GID $ARK_GID"
echo "###########################################################################"

[ -p /tmp/FIFO ] && rm /tmp/FIFO
mkfifo /tmp/FIFO

export TERM=linux

function stop {
	if [ "${BACKUPONSTOP}" -eq 1 ] && [ "$(ls -A /ark/server/install/ShooterGame/Saved)" ]; then
		echo "[Backup on stop]"
		arkmanager backup
	fi
	if [ "${WARNONSTOP}" -eq 1 ];then
	    arkmanager stop --warn
	else
	    arkmanager stop
	fi
	exit
}

# Change working directory to /ark to allow relative path
cd /ark || exit 1

# Add a template directory to store the last version of config file
mkdir -p /ark/config/template

# We overwrite the template file each time
cp -f /home/steam/arkmanager.cfg /ark/config/template/arkmanager.cfg
cp -f /home/steam/crontab /ark/config/template/crontab
cp -f /home/steam/instance.cfg /ark/config/template/instance.cfg

# Creating directory tree && symbolic link
mkdir -p /ark/config
mkdir -p /ark/log
mkdir -p /ark/backup
mkdir -p /ark/server/staging
mkdir -p /ark/config/instances
mkdir -p /home/steam/.config/arkmanager

ln -sf /ark/config/instances /home/steam/.config/arkmanager/instances

cp -n /home/steam/arkmanager.cfg /ark/config/arkmanager.cfg
cp -n /home/steam/instance.cfg /ark/config/instances/main.cfg
cp -n /ark/template/crontab /ark/config/crontab

[ ! -f /ark/config/Game.ini ] && [ -f /ark/server/install/ShooterGame/Saved/Config/LinuxServer/Game.ini ] && cp /ark/server/install/ShooterGame/Saved/Config/LinuxServer/Game.ini /ark/config/Game.ini
[ ! -f /ark/config/GameUserSettings.ini ] && [ -f /ark/server/install/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini ]  && cp /ark/server/install/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini /ark/config/GameUserSettings.ini

# Replace environment variables, since they do not work consistently with arkmanager.
(envsubst < /ark/config/arkmanager.cfg) > /ark/config/arkmanager.cfg.temp
mv /ark/config/arkmanager.cfg.temp /ark/config/arkmanager.cfg

if [ ! -d /ark/server/install  ] || [ ! -f /ark/server/install/PackageInfo.bin ];then
	echo "No game files found. Installing..."
	mkdir -p /ark/server/install/ShooterGame/Saved/SavedArks
	mkdir -p /ark/server/install/ShooterGame/Content/Mods
	mkdir -p /ark/server/install/ShooterGame/Binaries/Linux/
	touch /ark/server/install/ShooterGame/Binaries/Linux/ShooterGameServer
	arkmanager install
	# Create mod dir
else
	if [[ "${BACKUPONSTART}" -eq 1 ]] && [ "$(ls -A /ark/server/install/ShooterGame/Saved/SavedArks/)" ]; then
		echo "[Backup]"
		arkmanager backup
	fi
fi

#copying the actual configs
echo "Copying the config files..."
[[ -f /ark/config/Game.ini ]] && cp /ark/config/Game.ini /ark/server/install/ShooterGame/Saved/Config/LinuxServer/Game.ini
[[ -f /ark/config/GameUserSettings.ini ]] && cp /ark/config/GameUserSettings.ini /ark/server/install/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini

# Get instances info
arkmanager list-instances
mapfile -t instances < <( /usr/local/bin/arkmanager list-instances --brief )
echo "Found ${#instances[@]} instances"

# Launching ark server
for inst in "${instances[@]}"; do
  echo "Starting $inst"
  if [[ "$UPDATEONSTART" -eq 0 ]]; then
    arkmanager start --noautoupdate "@$inst"
  else
    arkmanager start "@$inst"
  fi
done

# Installing crontab for user steam
echo "Loading crontab..."
crontab /ark/config/crontab


# Stop server in case of signal INT or TERM
echo "Server Finished Loading!  Waiting for stop..."
trap stop INT
trap stop TERM

read -r < /tmp/FIFO &
wait

arkmanager stop @all --saveworld
