# Budgie Pixel Saver
This applet shows the active window's title and its minimize, maximize and close buttons inside the panel. Inspired from gnome extension pixel-saver.

Version 5 is a port to Budgie Desktop 10.10 (Wayland, libpeas-2). It works on any compositor that supports
wlr-foreign-toplevel (labwc, wayfire). Two things from the X11 version are gone:

* Hiding the real title bar of maximized windows: on Wayland a panel applet can't change another
  window's decorations. Use your compositor's settings for that (e.g. a labwc window rule).
* The "Hide for Client Side Decorated windows" option: whether a window draws its own title bar isn't
  visible to the panel on Wayland.

![Screenshot](screenshot.jpg)

* Added settings to choose action buttons and title bar visibility. This way its possible to create different layouts with multiple applets.
* Added settings to set title length.

![Screenshot](screenshot2.jpg)

---

## Dependencies
```
budgie-3.0 (Budgie Desktop >= 10.10)
gtk+-3.0 >= 3.24
glib-2.0 >= 2.64
libpeas-2
libxfce4windowing-0 >= 4.19.3 (and libxfce4windowingui-0)
vala
meson, ninja
```

### Installing

**From source**  
```bash
mkdir build && cd build
meson setup --prefix /usr --buildtype=plain ..
ninja
sudo ninja install
```

### License
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or at your option) any later version.

Workspaces applet of Budgie Desktop is used as a templete for this project. Spacer applet used as a templete in implementing settings.
