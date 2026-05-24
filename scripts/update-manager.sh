#!/usr/bin/env bash
#/home/israel/.config/hypr/scripts/update-manager.sh
official=$(checkupdates 2>/dev/null | wc -l)
aur=$(yay -Qua 2>/dev/null | wc -l)

updates=$((official + aur))

critical=0
reboot=0

critical_packages=$(checkupdates 2>/dev/null | grep -E "linux|nvidia|systemd|glibc|hyprland|pipewire")

if [ -n "$critical_packages" ]; then
    critical=1
fi

if [ -f /var/run/reboot-required ] || [ -n "$(checkupdates 2>/dev/null | grep -E 'linux|nvidia')" ]; then
    reboot=1
fi

class="stable"
icon="󰏖"
status="Stable"

if [ "$updates" -eq 0 ]; then
    class="updated"
    icon="󰄬"
fi

if [ "$critical" -eq 1 ]; then
    class="critical"
    icon="󰀦"
fi

if grep -q "^\[.*testing.*\]" /etc/pacman.conf; then
    class="testing"
    icon="󰚰"
fi

reboot_text="No"

if [ "$reboot" -eq 1 ]; then
    reboot_text="Sí"
fi

tooltip="󰣇 Official: $official\\n󰚰 AUR: $aur\\n󰏗 Mode: $status\\n󰌾 Reboot: $reboot_text\\n\\n󰖟 Left Click → Update Center\\n󰆓 Right Click → Quick Update"

printf '{"text":"%s %s","tooltip":"%s","class":"%s"}\n' \
    "$icon" \
    "$updates" \
    "$tooltip" \
    "$class"