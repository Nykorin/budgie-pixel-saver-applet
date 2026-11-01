namespace PixelSaver {

/**
 * The box an applet's widgets sit in. It's a GtkBox (so it can turn vertical on side
 * panels) that calls itself "headerbar" in CSS, so themes style the title and buttons
 * as they style a window's title bar.
 */
public class TitleBox : Gtk.Box
{
    /* Undoes what themes give a window's header bar itself, so only the buttons and
     * title keep the theme's look. Priority just above USER: a theme copied into
     * ~/.config/gtk-3.0/gtk.css (USER priority) would otherwise paint the header bar's
     * background behind the applets on a transparent panel. It only touches the box,
     * so the buttons' own styling still comes from the theme and the user's CSS. */
    const string CSS = """
        headerbar.pixel-saver {
            background: none;
            border: none;
            border-radius: 0;
            box-shadow: none;
            min-height: 0;
            margin: 0;
            padding: 0 4px;
        }
        headerbar.pixel-saver button.titlebutton {
            margin-top: 0;
            margin-bottom: 0;
        }
    """;
    static Gtk.CssProvider? css_provider = null;

    class construct {
        set_css_name("headerbar");
    }

    public TitleBox() {
        Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 0);
        install_css();
        this.get_style_context().add_class("titlebar");
        this.get_style_context().add_class("pixel-saver");
    }

    private static void install_css() {
        if (css_provider != null) return;

        css_provider = new Gtk.CssProvider();
        try {
            css_provider.load_from_data(CSS);
        } catch (Error e) {
            warning("Could not load the applet's CSS: %s", e.message);
        }
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_USER + 1);
    }

    /** Lays the box out along the panel: vertical on left and right panels. */
    public void set_panel_position(Budgie.PanelPosition position) {
        if (position == Budgie.PanelPosition.LEFT || position == Budgie.PanelPosition.RIGHT) {
            this.orientation = Gtk.Orientation.VERTICAL;
        } else {
            this.orientation = Gtk.Orientation.HORIZONTAL;
        }
    }
}

/**
 * Connects to the shared TitleBarManager for as long as a widget lives: the manager
 * outlives the applets, so their handlers have to go when an applet is removed.
 */
public class ManagerConnections : Object {
    private ulong[] handlers = {};
    public TitleBarManager manager { get; private set; }

    public ManagerConnections(Gtk.Widget owner) {
        this.manager = TitleBarManager.INSTANCE;
        owner.destroy.connect(() => {
            foreach (ulong id in this.handlers) {
                this.manager.disconnect(id);
            }
            this.handlers = {};
        });
    }

    public void add(ulong handler_id) {
        this.handlers += handler_id;
    }
}

}

namespace PixelSaver {

/** An applet settings page: one row per setting, the label on the left. */
public class SettingsGrid : Gtk.Grid {
    private int rows = 0;

    public SettingsGrid() {
        Object(row_spacing: 8, column_spacing: 12, margin: 8);
    }

    public void add_row(string label, Gtk.Widget widget) {
        var text = new Gtk.Label(label);
        text.halign = Gtk.Align.START;
        text.hexpand = true;
        text.wrap = true;
        text.xalign = 0;
        widget.halign = Gtk.Align.END;
        widget.valign = Gtk.Align.CENTER;
        this.attach(text, 0, this.rows);
        this.attach(widget, 1, this.rows);
        this.rows++;
    }

    /** A note under the rows, across both columns. */
    public void add_note(Gtk.Label note) {
        note.halign = Gtk.Align.START;
        note.xalign = 0;
        note.wrap = true;
        note.max_width_chars = 36;
        note.get_style_context().add_class("dim-label");
        this.attach(note, 0, this.rows, 2);
        this.rows++;
    }

    public Gtk.Switch add_switch(Settings settings, string key, string label) {
        var sw = new Gtk.Switch();
        settings.bind(key, sw, "active", SettingsBindFlags.DEFAULT);
        this.add_row(label, sw);
        return sw;
    }
}

}
