#!/usr/bin/env bash

cfg="$1"

[[ -z "$cfg" ]] && exit 1
[[ ! -f "$cfg" ]] && exit 2

instPath="$(/usr/local/bin/check-shallow-ark "$cfg")"
[[ -z "$instPath" ]] && exit 3

instName=$(basename -s .cfg "$cfg")

/usr/local/bin/ark-gen-shallow "$instPath"
/usr/local/bin/ark-set-shallow-save "$instPath" "$instName"
