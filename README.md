# Budgie Pixel Saver
Two panel applets that put the active window's title and its minimize, maximize and close buttons
in the panel. Inspired from gnome extension pixel-saver.

* **Pixel Saver Title**: the active window's title. Double-click it to (un)maximize the window,
  right-click it for the window menu. Settings: title length, hide while the window isn't maximized.
* **Pixel Saver Buttons**: minimize, maximize and close buttons. Settings: which buttons to show
  and in what order, hide while the window isn't maximized.

  The buttons are given as lowercase names (`minimize`, `maximize`, `close`) separated by spaces,
  e.g. `close minimize maximize`, or just `close` for a lone close button. Buttons left out aren't
  shown, and words that aren't button names are ignored (the settings field marks them). Left empty,
  all three show in Budgie's window button layout.

Add each applet as often as you like: every copy has its own settings, so you can, for example, put the
title on the left and a lone close button at the far right. The buttons take the GTK theme's window
title bar button style.

Version 5 is a port to Budgie Desktop 10.10 (Wayland, libpeas-2). It works on any compositor that
supports wlr-foreign-toplevel (labwc, wayfire). Compared with the X11 version:

* The single "Budgie Pixel Saver" applet is now these two applets; panels that had it need them added.
* Hiding the real title bar of maximized windows is gone: on Wayland a panel applet can't change another
  window's decorations. Use your compositor's settings for that (e.g. a labwc window rule).
* The "Hide for Client Side Decorated windows" option is gone: whether a window draws its own title bar
  isn't visible to the panel on Wayland.

![Screenshot](screenshot.jpg)

---

## Dependencies
```
budgie-3.0 (Budgie Desktop >= 10.10)
gtk+-3.0 >= 3.24
glib-2.0 >= 2.64
libpeas-2
libxfce4windowing-0 >= 4.19.3 (and libxfce4windowingui-0)
vala
meson >= 1.11, ninja
```

### Installing

**From source**  
```bash
mkdir build && cd build
meson setup --prefix /usr --buildtype=plain ..
ninja
meson test        # optional: checks the button order parsing
sudo ninja install
```

### License
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or at your option) any later version.

Workspaces applet of Budgie Desktop is used as a templete for this project. Spacer applet used as a templete in implementing settings.
