#!/usr/bin/env bash

instPath=$1
saveName=$2

[[ -z "$instPath" ]] && exit 1
[[ -z "$saveName" ]] && exit 2

fullSave="/ark/saves/"$2""
targetSave="${instPath}/ShooterGame/Saved"

echo "Linking save path "$fullSave" to shallow instance "$targetSave""

mkdir -p "$fullSave"

[[ -d "$targetSave" ]] && rm -Rf "$targetSave"
ln -sf "$fullSave" "$targetSave"
[[ "$saveName" -ne "main" ]] && ln -sf /ark/saves/main/clusters "${targetSave}/clusters"
