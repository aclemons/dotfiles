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

[ -x /usr/bin/vmware-user ] && /usr/bin/vmware-user

export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx

cat "$HOME/.config/i3/config.base" > "$HOME/.config/i3/config"
cat "$HOME/.config/i3/config.$(hostname)" >> "$HOME/.config/i3/config"

if grep ubuntu /etc/os-release > /dev/null 2>&1 ; then
  sed -i '/^tiling_drag modifier/d' "$HOME/.config/i3/config"
fi

# Start i3
if [ "$(gpg2 --version | sed -n 1p | cut -d' ' -f3 | cut -d. -f2)" = "0" ] ; then
  if [ -z "$DESKTOP_SESSION" -a -x /usr/bin/ck-launch-session ]; then
    exec ssh-agent gpg-agent --daemon ck-launch-session dbus-launch --exit-with-session /usr/bin/i3
  else
    exec ssh-agent gpg-agent --daemon /usr/bin/i3
  fi
else
  if [ -z "$DESKTOP_SESSION" -a -x /usr/bin/ck-launch-session ]; then
    exec ssh-agent ck-launch-session dbus-launch --exit-with-session /usr/bin/i3
  else
    exec ssh-agent /usr/bin/i3
  fi
fi
