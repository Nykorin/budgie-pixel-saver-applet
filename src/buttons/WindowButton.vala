namespace PixelSaver {

/** Buttons the applet can show, in their default order. */
[CCode (has_type_id = false)]
public enum WindowButton {
    MINIMIZE,
    MAXIMIZE,
    CLOSE;

    public static WindowButton? from_name(string name) {
        switch (name) {
            case "minimize": return MINIMIZE;
            case "maximize": return MAXIMIZE;
            case "close": return CLOSE;
            default: return null;
        }
    }

    /**
     * The buttons to show, in order, from the "order" setting: lowercase button
     * names separated by spaces. Buttons it leaves out aren't shown; with no button
     * names at all, it's default_order. Words that aren't button names go to unknown.
     */
    public static WindowButton[] parse_order(string text, WindowButton[] default_order, out string[] unknown) {
        WindowButton[] order = {};
        string[] bad = {};
        foreach (string word in text.split(" ")) {
            if (word == "") continue;
            WindowButton? button = from_name(word);
            if (button == null) {
                bad += word;
            } else if (!contains(order, button)) {
                order += button;
            }
        }
        unknown = bad;
        return order.length > 0 ? order : default_order;
    }

    public static bool contains(WindowButton[] list, WindowButton button) {
        foreach (WindowButton b in list) {
            if (b == button) return true;
        }
        return false;
    }
}

}
