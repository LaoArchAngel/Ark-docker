#!/usr/bin/env bash

for cfg in /ark/config/instances/*.cfg; do
    [[ "$cfg" == *"/main.cfg" ]] && continue

    /usr/local/bin/ark-create-shallow "$cfg"
done
