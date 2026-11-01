namespace PixelSaver {

/** Buttons the applet can show, in their default order. */
[CCode (has_type_id = false)]
public enum WindowButton {
    MINIMIZE,
    MAXIMIZE,
    CLOSE;

    public static WindowButton? from_name(string name) {
        switch (name.down()) {
            case "minimize": return MINIMIZE;
            case "maximize": return MAXIMIZE;
            case "close": return CLOSE;
            default: return null;
        }
    }

    /**
     * The button order from the "order" setting: full names separated by commas
     * and/or spaces, any case. Buttons it leaves out follow in default_order.
     * Words that aren't button names go to unknown.
     */
    public static WindowButton[] parse_order(string text, WindowButton[] default_order, out string[] unknown) {
        WindowButton[] order = {};
        string[] bad = {};
        foreach (string word in Regex.split_simple("[,\\s]+", text.strip())) {
            if (word == "") continue;
            WindowButton? button = from_name(word);
            if (button == null) {
                bad += word;
            } else if (!contains(order, button)) {
                order += button;
            }
        }
        foreach (WindowButton button in default_order) {
            if (!contains(order, button)) order += button;
        }
        unknown = bad;
        return order;
    }

    private static bool contains(WindowButton[] list, WindowButton button) {
        foreach (WindowButton b in list) {
            if (b == button) return true;
        }
        return false;
    }
}

}
