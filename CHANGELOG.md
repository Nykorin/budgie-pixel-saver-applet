# Changelog

All notable changes made on top of upstream commit 773c8bd (ilgarmehmetali/budgie-pixel-saver-applet, version 4.0.0). Dates are local time.

Contributors: Mehmet Ali İLGAR (original applet), user (design & direction), Claude (port)

Each bullet starts with the file it touches; paths are relative to the repository root.

## [2026-11-01]

### Added
- **CHANGELOG.md:** This file, for the changes made on top of upstream *(Claude, directed by user)*

### Changed
- **src/TitleBarManager.vala:** Tracks the active window through libxfce4windowing instead of libwnck, so it works on Wayland (wlr-foreign-toplevel: labwc, wayfire) as well as X11; minimize, (un)maximize and close go through it. The shown window stays until it's minimized or closed, as clicking the panel can take the focus from it, and `refresh()` re-emits the state for an applet that has just connected. The active-window handler is a method with a nullable argument: the libxfce4windowing vapi marks the previous window non-null, so a lambda rejected the NULL sent when no window was active before. Tested in a nested Budgie 10.10 session on labwc *(Claude, directed by user)*
- **src/BudgiePixelSaverApplet.vala:** Built against budgie-3.0 and libpeas-2; the right-click menu is `Xfw.WindowActionMenu`; `com.solus-project.budgie-wm` is read only when installed; deprecated GTK calls replaced *(Claude, directed by user)*
- **meson.build, src/meson.build:** Dependencies are budgie-3.0, libpeas-2 and libxfce4windowing-0 (with its ui library) instead of budgie-1.0, libpeas-1.0, libwnck and gdk-x11; version 5.0.0; the schema installs under the prefix instead of `/usr` *(Claude, directed by user)*
- **src/BudgiePixelSaverApplet.plugin.in:** `Module=` follows Budgie 10.10's naming; a description of what the applet shows *(Claude, directed by user)*
- **README.md:** The "Abandoned" note is gone; what the port changes, and the new dependencies *(Claude, directed by user)*

### Removed
- **src/TitleBarManager.vala:** Hiding the real title bar of maximized windows (`xprop` setting `_GTK_HIDE_TITLEBAR_WHEN_MAXIMIZED`): on Wayland a panel applet can't change another window's decorations, and the compositor is no longer budgie-wm *(Claude, directed by user)*
- **src/settings.ui, src/net.milgar.budgie-pixel-saver.gschema.xml:** The "Hide for Client Side Decorated windows" option: on Wayland the panel can't see whether a window draws its own title bar *(Claude, directed by user)*

