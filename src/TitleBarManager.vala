namespace PixelSaver {

/**
 * Tracks the active window through libxfce4windowing (wlr-foreign-toplevel on
 * Wayland, X11 otherwise) and acts on it. One instance is shared by every applet.
 */
public class TitleBarManager : Object {

    private Xfw.Screen screen;
    private Xfw.Window? active_window;

    private static TitleBarManager? instance;

    public static TitleBarManager INSTANCE {
        get {
            if (instance == null) {
                instance = new TitleBarManager();
            }
            return instance;
        }
    }

    public signal void on_title_changed (string title);
    public signal void on_window_state_changed (bool is_maximized);
    public signal void on_active_window_changed (bool can_minimize, bool can_maximize, bool can_close, bool is_active_window_maximized);

    private TitleBarManager()
    {
        this.screen = Xfw.Screen.get_default();

        // A method rather than a lambda: the vapi has `previous` as non-null, but it's
        // NULL when no window was active before, and a lambda would reject that
        this.screen.active_window_changed.connect(this.on_screen_active_window_changed);
        this.screen.window_closed.connect((window) => {
            if (window == this.active_window) {
                this.update_active_window(this.screen.get_active_window());
            }
        });

        this.update_active_window(this.screen.get_active_window());
    }

    /** Re-emits the current state, for an applet that has just connected. */
    public void refresh() {
        this.emit_title();
        this.emit_active_window_changed();
    }

    public Gtk.Menu? get_action_menu_for_active_window() {
        if (this.active_window == null) return null;

        return new Xfw.WindowActionMenu(this.active_window);
    }

    public void close_active_window(){
        if (this.active_window == null) return;

        try {
            this.active_window.close(Gtk.get_current_event_time());
        } catch (Error e) {
            warning("Could not close window: %s", e.message);
        }
    }

    public void toggle_maximize_active_window(){
        if (this.active_window == null) return;

        try {
            this.active_window.set_maximized(!this.active_window.is_maximized());
        } catch (Error e) {
            warning("Could not (un)maximize window: %s", e.message);
        }
    }

    public void minimize_active_window(){
        if (this.active_window == null) return;

        try {
            this.active_window.set_minimized(true);
        } catch (Error e) {
            warning("Could not minimize window: %s", e.message);
        }
    }

    private static bool is_tracked(Xfw.Window? window) {
        return window != null
            && window.get_window_type() == Xfw.WindowType.NORMAL
            && !window.is_skip_tasklist();
    }

    private void update_active_window(Xfw.Window? new_window) {
        if (!is_tracked(new_window)) {
            // Clicking the panel or the desktop can take the focus away from the
            // window; keep showing it until it's minimized or closed.
            if (this.active_window != null && !this.active_window.is_minimized()
                && this.screen.get_windows().find(this.active_window) != null) {
                return;
            }
            new_window = null;
        }

        if (new_window != this.active_window) {
            if (this.active_window != null) {
                SignalHandler.disconnect_by_data(this.active_window, this);
            }
            this.active_window = new_window;
            if (this.active_window != null) {
                this.active_window.name_changed.connect(this.on_active_window_name_changed);
                this.active_window.state_changed.connect(this.on_active_window_state_changed);
                this.active_window.capabilities_changed.connect(this.on_active_window_capabilities_changed);
            }
        }

        this.emit_title();
        this.emit_active_window_changed();
    }

    private void emit_title() {
        string? name = this.active_window != null ? this.active_window.get_name() : null;
        this.on_title_changed(name ?? "");
    }

    private void emit_active_window_changed() {
        bool can_minimize = false;
        bool can_maximize = false;
        bool can_close = false;
        bool is_maximized = false;

        if (this.active_window != null) {
            Xfw.WindowCapabilities caps = this.active_window.get_capabilities();
            is_maximized = this.active_window.is_maximized();
            can_minimize = Xfw.WindowCapabilities.CAN_MINIMIZE in caps;
            can_maximize = (is_maximized ? Xfw.WindowCapabilities.CAN_UNMAXIMIZE
                                         : Xfw.WindowCapabilities.CAN_MAXIMIZE) in caps;
            can_close = true;
        }
        this.on_active_window_changed(can_minimize, can_maximize, can_close, is_maximized);
    }

    private void on_screen_active_window_changed(Xfw.Window? previous) {
        this.update_active_window(this.screen.get_active_window());
    }

    private void on_active_window_name_changed(){
        this.emit_title();
    }

    private void on_active_window_state_changed(Xfw.WindowState changed_mask, Xfw.WindowState new_state){
        if (Xfw.WindowState.MINIMIZED in new_state) {
            this.update_active_window(this.screen.get_active_window());
            return;
        }
        if (Xfw.WindowState.MAXIMIZED in changed_mask) {
            this.on_window_state_changed(Xfw.WindowState.MAXIMIZED in new_state);
            this.emit_active_window_changed();
        }
    }

    private void on_active_window_capabilities_changed(Xfw.WindowCapabilities changed_mask, Xfw.WindowCapabilities new_caps){
        this.emit_active_window_changed();
    }
}
}
