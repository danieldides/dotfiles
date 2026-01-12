#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# define Xresources
userresources=$HOME/.Xresources

# merge in resources
if [ -f "$userresources" ]; then
	xrdb -merge "$useresources"
fi

[[ -f !/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

xrdb $HOME/.Xresources &
# xcompmgr &
xmodmap ~/.Xmodmap &
picom --config /home/daniel.config/picom.conf &
unclutter &
nm-applet &
blueman-applet &
xfce4-power-manager &
redshift-gtk &
udiskie &
thunar --daemon &
pasystray &

DEFAULT_SESSION=awesome

exec awesome
