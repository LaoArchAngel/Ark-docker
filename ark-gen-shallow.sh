#!/bin/bash

instPath=$1

[[ -z "$instPath" ]] && exit 1

echo "Generating shallow instance @ "$instPath""
[[ -d "$instPath" ]] &&  rm -Rf "$instPath"

cp -Ras /ark/server/install "$instPath"
