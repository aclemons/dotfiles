#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# Merge in defaults and keymaps
[ -f $sysresources ] && /usr/bin/xrdb -merge $sysresources
[ -f $sysmodmap ] && /usr/bin/xmodmap $sysmodmap
[ -f $userresources ] && /usr/bin/xrdb -merge $userresources
[ -f $usermodmap ] && /usr/bin/xmodmap $usermodmap

dbus-update-activation-environment DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

[ -x /usr/bin/vmware-user ] && /usr/bin/vmware-user
[ -x /usr/bin/spice-vdagent ] && /usr/bin/spice-vdagent

export XMODIFIERS=@im=fcitx5
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5

cat "$HOME/.config/i3/config.base" > "$HOME/.config/i3/config"
cat "$HOME/.config/i3/config.$(hostname)" >> "$HOME/.config/i3/config"

if grep ubuntu /etc/os-release > /dev/null 2>&1 ; then
  sed -i '/^tiling_drag modifier/d' "$HOME/.config/i3/config"
fi

if [ "$(hostname)" = "iitpc22-0139-vm" ] ; then
  xmodmap -e "keycode 100 = ISO_Level3_Shift"
fi

# Start i3
if [ -z "$DESKTOP_SESSION" ] && [ -x /usr/bin/ck-launch-session ]; then
  exec ssh-agent ck-launch-session dbus-launch --exit-with-session /usr/bin/i3
elif [ -x /usr/bin/dbus-launch ]; then
  exec ssh-agent dbus-launch --exit-with-session /usr/bin/i3
else
  exec ssh-agent /usr/bin/i3
fi
