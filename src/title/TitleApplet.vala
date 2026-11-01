namespace PixelSaver {

public class TitlePlugin : Budgie.Plugin, Peas.ExtensionBase
{
    public Budgie.Applet get_panel_widget(string uuid)
    {
        return new TitleApplet(uuid);
    }
}

/** The active window's title. Double-click (un)maximizes it, right-click opens its menu. */
public class TitleApplet : Budgie.Applet
{
    Gtk.Label label;
    Gtk.EventBox event_box;
    TitleBox container;

    bool is_active_window_maximized = false;

    public string uuid { public set; public get; }

    private Settings settings;
    private ManagerConnections connections;

    public TitleApplet(string uuid)
    {
        Object(uuid: uuid);

        this.label = new Gtk.Label("");
        this.label.set_ellipsize(Pango.EllipsizeMode.END);
        this.label.xalign = 0;
        this.label.yalign = 0.5f;
        this.label.get_style_context().add_class("title");

        this.event_box = new Gtk.EventBox();
        this.event_box.add(this.label);

        this.container = new TitleBox();
        this.container.pack_start(this.event_box, false, false, 0);
        this.add(this.container);

        this.connections = new ManagerConnections(this);
        var manager = this.connections.manager;

        this.event_box.button_press_event.connect((event) => {
            if (event.type == Gdk.EventType.@2BUTTON_PRESS && event.button == 1) {
                manager.toggle_maximize_active_window();
            }
            return Gdk.EVENT_PROPAGATE;
        });

        this.event_box.button_release_event.connect((event) => {
            if (event.button != 3) return Gdk.EVENT_PROPAGATE;

            Gtk.Menu? menu = manager.get_action_menu_for_active_window();
            if (menu == null) return Gdk.EVENT_PROPAGATE;
            menu.attach_to_widget(this.event_box, null);
            menu.deactivate.connect(() => { menu.destroy(); });
            menu.show_all();
            menu.popup_at_pointer(event);
            return Gdk.EVENT_STOP;
        });

        this.connections.add(manager.on_title_changed.connect((title) => {
            this.label.set_text(title);
            this.label.set_tooltip_text(title);
        }));
        this.connections.add(manager.on_window_state_changed.connect((is_maximized) => {
            this.is_active_window_maximized = is_maximized;
            this.update_visibility();
        }));
        this.connections.add(manager.on_active_window_changed.connect((can_minimize, can_maximize, can_close, is_maximized) => {
            this.is_active_window_maximized = is_maximized;
            this.update_visibility();
        }));

        this.settings_schema = "net.milgar.budgie-pixel-saver.title";
        this.settings_prefix = "/net/milgar/budgie-pixel-saver-title";
        this.settings = this.get_applet_settings(uuid);
        this.settings.changed.connect(this.on_settings_changed);

        show_all();
        this.on_settings_changed("size");
        manager.refresh();
    }

    void on_settings_changed(string key) {
        if (key == "size") {
            this.label.set_max_width_chars(this.settings.get_int(key));
            this.label.set_width_chars(this.settings.get_int(key));
        }
        this.update_visibility();
    }

    void update_visibility() {
        bool hide = !this.is_active_window_maximized && this.settings.get_boolean("hide-for-unmaximized");
        this.label.visible = !hide;
        queue_resize();
    }

    public override void panel_position_changed(Budgie.PanelPosition position)
    {
        this.container.set_panel_position(position);
        if (position == Budgie.PanelPosition.LEFT) {
            this.label.angle = 90;
            this.label.xalign = 0.5f;
            this.label.yalign = 1;
        } else if (position == Budgie.PanelPosition.RIGHT) {
            this.label.angle = 270;
            this.label.xalign = 0.5f;
            this.label.yalign = 0;
        } else {
            this.label.angle = 0;
            this.label.xalign = 0;
            this.label.yalign = 0.5f;
        }
    }

    public override bool supports_settings() {
        return true;
    }

    public override Gtk.Widget? get_settings_ui()
    {
        var settings = this.get_applet_settings(this.uuid);
        var grid = new SettingsGrid();

        var length = new Gtk.SpinButton.with_range(0, 100, 1);
        settings.bind("size", length, "value", SettingsBindFlags.DEFAULT);
        grid.add_row("Title length", length);
        grid.add_switch(settings, "hide-for-unmaximized", "Hide for unmaximized windows");

        grid.show_all();
        return grid;
    }
}

}

[ModuleInit]
public void peas_register_types(TypeModule module)
{
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(PixelSaver.TitlePlugin));
}
