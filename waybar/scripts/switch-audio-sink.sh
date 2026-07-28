#!/usr/bin/env bash
# Lists PipeWire sinks via wpctl and switches the default one via rofi

mapfile -t lines < <(wpctl status | awk '/Sinks:/{f=1; next} /Sources:/{f=0} f' \
  | sed -E 's/^\s*[│├└─*]*\s*//' | grep -E '^[0-9]+\.')

choice=$(printf '%s\n' "${lines[@]}" | rofi -dmenu -p "Audio Output")
id=$(echo "$choice" | grep -oP '^\d+')

[ -n "$id" ] && wpctl set-default "$id"