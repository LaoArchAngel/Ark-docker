#!/bin/bash

instPath=$1

[[ -z "$instPath" ]] && exit 1

echo "Generating shallow instance @ "$instPath""
[[ -d "$instPath" ]] &&  rm -Rf "$instPath"

cp -Ras /ark/server/install "$instPath"

modPath="${instPath}/ShooterGame/Content/Mods"
rm -Rf "$modPath"
# Mods need to be done as a folder instead of per mod.
ln -s /ark/server/install/ShooterGame/Content/Mods "$modPath"
