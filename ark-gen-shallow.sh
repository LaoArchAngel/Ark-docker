#!/usr/bin/env bash

instPath=$1

[[ -z "$instPath" ]] && exit 1

echo "Generating shallow instance @ $instPath"
rm -Rf "$instPath"
cp -Ral /ark/server/install "$instPath"
