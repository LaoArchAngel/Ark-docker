#!/bin/bash

instPath=$1
saveName=$2

[[ -z "$instPath" ]] $$ exit 1
[[ -z "$saveName" ]] $$ exit 2

fullSave="/ark/saves/"$2""
targetSave="${instPath}/ShooterGame/Saved"

echo "Linking save path "$fullSave" to shallow instance "$targetSave""

[[ ! -d "$fullSave" ]] && mkdir "$fullSave"

[[ -d "$targetSave" ]] && rm -Rf "$targetSave"
ln -s "$fullSave" "$targetSave"
