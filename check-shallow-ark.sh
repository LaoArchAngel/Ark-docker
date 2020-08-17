#!/usr/bin/env bash

cfg="$1"

[[ -z "$cfg" ]] && exit 1
[[ ! -f "$cfg" ]] && exit 2
[[ "$cfg" == *"/main.cfg" ]] && exit 0

arkRoot=$(grep "arkserverroot" "$cfg")
[[ -n "$arkRoot" ]] && arkRoot="$(echo "$arkRoot" | cut -d = -f 2)"

if [[ -n "$arkRoot" ]]; then
    [[ "$arkRoot" != "/ark/server/instances"* ]] && exit 0
fi

if [[ -z "$arkRoot" ]]; then
    arkRoot="/ark/server/instances/$(basename -s .cfg "$cfg")"
    echo "" >> "$cfg" #ensure empty line
    echo "arkserverroot=$arkRoot" >> "$cfg" # save new arkRoot
fi

echo "$arkRoot"

exit 0
