#!/bin/sh
# ~/.config/dwl/autostart.sh

# 1. Environment & D-Bus
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
/usr/lib/pass-secret-service &

# 2. GTK / GNOME Schemas
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'

# 3. Daemons (Notifications, Clipboard, Wallpaper)
mako &
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
#swaybg -i /home/murat/.wallpaper/rachel-davis-tn2rBnvIl9I-unsplash.jpg -m fill &

# 4. Status Bar (e.g., somebar, waybar)
# exec somebar
