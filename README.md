# bash_utils

This is command line environment customization of korpiq. There are many like it, but this one is mine.

## setup

    ./setup


Files under `hosts/<hostname>/home` and `hosts/<hostname>/system` are
installed like `home` and `system`, but only on the host named
`<hostname>`.

`./setup` is not meant to be run as is. Treat it, like the other setup scripts, as a hint of what should be done manually, or by separate setup scripts. Those have their own sections below.

## setup-keyd

    ./setup-keyd

Installs [keyd](https://github.com/rvaiya/keyd) and `system/etc/keyd/default.conf` as `/etc/keyd/default.conf`, and restarts the service. On KDE it also removes the `caps:` option from the keyboard layout options in `kxkbrc`, so that KDE does not remap what keyd emits. Log out and in for that to take effect; until then KDE keeps applying the old option and Caps Lock misbehaves.

Key mappings:

- Caps Lock and Right Control: Escape when tapped, Control when held.
- Pause: Tab, for tabbing while typing on the numpad.
- Shift+Caps Lock: toggles Caps Lock.

keyd works under Wayland, X11, and the console.
