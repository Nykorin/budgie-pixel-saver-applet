namespace PixelSaver {

public class ButtonsPlugin : Budgie.Plugin, Peas.ExtensionBase
{
    public Budgie.Applet get_panel_widget(string uuid)
    {
        return new ButtonsApplet(uuid);
    }
}

/** Minimize, maximize and close buttons for the active window. */
public class ButtonsApplet : Budgie.Applet
{
    Gtk.Button minimize_button;
    Gtk.Button maximize_button;
    Gtk.Button close_button;
    Gtk.Image maximize_image;
    Gtk.Image restore_image;
    TitleBox container;

    bool is_active_window_maximized = false;
    WindowButton[] shown = {};

    public string uuid { public set; public get; }

    private Settings settings;
    private Settings? wm_settings = null;
    private ManagerConnections connections;

    public ButtonsApplet(string uuid)
    {
        Object(uuid: uuid);

        this.minimize_button = new_button("window-minimize-symbolic", "minimize", "Minimize");
        this.maximize_button = new_button("window-maximize-symbolic", "maximize", "Maximize");
        this.close_button = new_button("window-close-symbolic", "close", "Close");
        this.maximize_image = new Gtk.Image.from_icon_name("window-maximize-symbolic", Gtk.IconSize.BUTTON);
        this.restore_image = new Gtk.Image.from_icon_name("window-restore-symbolic", Gtk.IconSize.BUTTON);

        this.container = new TitleBox();
        this.container.pack_start(this.minimize_button, false, false, 0);
        this.container.pack_start(this.maximize_button, false, false, 0);
        this.container.pack_start(this.close_button, false, false, 0);
        this.add(this.container);

        this.connections = new ManagerConnections(this);
        var manager = this.connections.manager;

        this.minimize_button.clicked.connect(() => manager.minimize_active_window());
        this.maximize_button.clicked.connect(() => manager.toggle_maximize_active_window());
        this.close_button.clicked.connect(() => manager.close_active_window());

        this.connections.add(manager.on_window_state_changed.connect(this.on_maximized_changed));
        this.connections.add(manager.on_active_window_changed.connect((can_minimize, can_maximize, can_close, is_maximized) => {
            this.minimize_button.sensitive = can_minimize;
            this.maximize_button.sensitive = can_maximize;
            this.close_button.sensitive = can_close;
            this.on_maximized_changed(is_maximized);
        }));

        this.settings_schema = "net.milgar.budgie-pixel-saver.buttons";
        this.settings_prefix = "/net/milgar/budgie-pixel-saver-buttons";
        this.settings = this.get_applet_settings(uuid);
        this.settings.changed.connect(this.on_settings_changed);

        // Without an order of its own, the applet follows Budgie's window button layout
        var schema_source = SettingsSchemaSource.get_default();
        if (schema_source != null && schema_source.lookup("com.solus-project.budgie-wm", true) != null) {
            this.wm_settings = new Settings("com.solus-project.budgie-wm");
            this.wm_settings.changed["button-style"].connect(() => this.apply_order());
        }

        show_all();
        this.apply_order();
        manager.refresh();
    }

    private static Gtk.Button new_button(string icon, string style_class, string tooltip) {
        var button = new Gtk.Button.from_icon_name(icon);
        button.tooltip_text = tooltip;
        button.get_style_context().add_class("titlebutton");
        button.get_style_context().add_class(style_class);
        return button;
    }

    private void on_maximized_changed(bool is_maximized) {
        this.is_active_window_maximized = is_maximized;
        this.maximize_button.image = is_maximized ? this.restore_image : this.maximize_image;
        this.update_visibility();
    }

    void on_settings_changed(string key) {
        if (key == "order") {
            this.apply_order();
        } else {
            this.update_visibility();
        }
    }

    /** The buttons, in order, when the "order" setting names none. */
    private WindowButton[] default_order() {
        if (this.wm_settings != null && this.wm_settings.get_string("button-style") == "left") {
            return { WindowButton.CLOSE, WindowButton.MINIMIZE, WindowButton.MAXIMIZE };
        }
        return { WindowButton.MINIMIZE, WindowButton.MAXIMIZE, WindowButton.CLOSE };
    }

    private Gtk.Button button_for(WindowButton button) {
        switch (button) {
            case WindowButton.MINIMIZE: return this.minimize_button;
            case WindowButton.MAXIMIZE: return this.maximize_button;
            default: return this.close_button;
        }
    }

    /** Shows the buttons the "order" setting names, in its order; the others are hidden. */
    private void apply_order() {
        string[] unknown;
        this.shown = WindowButton.parse_order(this.settings.get_string("order"), this.default_order(), out unknown);
        for (int i = 0; i < this.shown.length; i++) {
            this.container.reorder_child(this.button_for(this.shown[i]), i);
        }
        this.update_visibility();
    }

    void update_visibility() {
        bool hide_all = !this.is_active_window_maximized && this.settings.get_boolean("hide-for-unmaximized");
        foreach (WindowButton button in new WindowButton[] { WindowButton.MINIMIZE, WindowButton.MAXIMIZE, WindowButton.CLOSE }) {
            this.button_for(button).visible = !hide_all && WindowButton.contains(this.shown, button);
        }
        queue_resize();
    }

    public override void panel_position_changed(Budgie.PanelPosition position)
    {
        this.container.set_panel_position(position);
    }

    public override bool supports_settings() {
        return true;
    }

    public override Gtk.Widget? get_settings_ui()
    {
        var settings = this.get_applet_settings(this.uuid);
        var grid = new SettingsGrid();

        var order = new Gtk.Entry();
        order.placeholder_text = "minimize maximize close";
        order.width_chars = 22;
        settings.bind("order", order, "text", SettingsBindFlags.DEFAULT);
        order.changed.connect(() => mark_unknown_names(order));
        mark_unknown_names(order);
        grid.add_row("Buttons", order);
        grid.add_note(new Gtk.Label("The buttons to show, in order: lowercase names "
            + "separated by spaces, e.g. \"close minimize\". Left empty, all three show "
            + "in Budgie's window button layout."));

        grid.add_switch(settings, "hide-for-unmaximized", "Hide for unmaximized windows");

        grid.show_all();
        return grid;
    }

    /** Shows a warning icon in the order entry while it has words that aren't button names. */
    private static void mark_unknown_names(Gtk.Entry entry) {
        string[] unknown;
        WindowButton.parse_order(entry.text, {}, out unknown);
        if (unknown.length == 0) {
            entry.secondary_icon_name = null;
            entry.secondary_icon_tooltip_text = null;
        } else {
            entry.secondary_icon_name = "dialog-warning-symbolic";
            entry.secondary_icon_tooltip_text = "Ignored: %s\nUse minimize, maximize or close, separated by spaces".printf(
                string.joinv(", ", unknown));
        }
    }
}

}

[ModuleInit]
public void peas_register_types(TypeModule module)
{
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(PixelSaver.ButtonsPlugin));
}
