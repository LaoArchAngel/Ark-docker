#!/bin/bash

cfg="$1"

[[ -z "$cfg" ]] && exit 1
[[ ! -f "$cfg" ]] && exit 2

arkroot=$(grep "arkserverroot" "$cfg")
[[ -n "$arkroot" ]] && arkroot="$(echo "$arkroot" | cut -d = -f 2)"

if [[ -n "$arkroot" ]]; then
    [[ "$arkroot" != "/ark/instances"* ]] && exit 0
fi

[[ -z "$arkroot" ]] && arkroot="/ark/instances/$(basename -s .cfg "$cfg")"

echo "$arkroot"

exit 0