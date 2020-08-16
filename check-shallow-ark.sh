#!/usr/bin/env bash

cfg="$1"

[[ -z "$cfg" ]] && exit 1
[[ ! -f "$cfg" ]] && exit 2

arkroot=$(grep "arkserverroot" "$cfg")
[[ -n "$arkroot" ]] && arkroot="$(echo "$arkroot" | cut -d = -f 2)"

if [[ -n "$arkroot" ]]; then
    [[ "$arkroot" != "/ark/server/instances"* ]] && exit 0
fi

if [[ -z "$arkroot" ]]; then
    arkroot="/ark/server/instances/$(basename -s .cfg "$cfg")"
    echo "" >> "$cfg" #ensure empty line
    echo "arkserverroot="$arkroot"" >> "$cfg" # save new arkroot
fi

echo "$arkroot"

exit 0
