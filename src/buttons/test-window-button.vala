using PixelSaver;

// Not MIN/MAX: those would replace GLib's MIN()/MAX() macros in the generated C
const WindowButton B_MIN = WindowButton.MINIMIZE;
const WindowButton B_MAX = WindowButton.MAXIMIZE;
const WindowButton B_CLOSE = WindowButton.CLOSE;
const WindowButton[] USUAL = { B_MIN, B_MAX, B_CLOSE };

void check(string text, WindowButton[] default_order, WindowButton[] expected, string[] expected_unknown) {
    string[] unknown;
    var order = WindowButton.parse_order(text, default_order, out unknown);
    assert_cmpint(order.length, CompareOperator.EQ, expected.length);
    for (int i = 0; i < expected.length; i++) {
        assert_cmpint(order[i], CompareOperator.EQ, expected[i]);
    }
    assert_cmpstrv(unknown, expected_unknown);
}

void main(string[] args) {
    Test.init(ref args);
    Test.add_func("/order/empty", () => check("", USUAL, USUAL, {}));
    Test.add_func("/order/blank", () => check("   ", USUAL, USUAL, {}));
    Test.add_func("/order/spaces", () => check("maximize close minimize", USUAL, { B_MAX, B_CLOSE, B_MIN }, {}));
    Test.add_func("/order/left-default", () => check("", { B_CLOSE, B_MIN, B_MAX }, { B_CLOSE, B_MIN, B_MAX }, {}));
    Test.add_func("/order/extra-spaces", () => check("  close   minimize ", USUAL, { B_CLOSE, B_MIN }, {}));
    Test.add_func("/order/capitals", () => check("Close MINIMIZE maximize", USUAL, { B_MAX }, { "Close", "MINIMIZE" }));
    Test.add_func("/order/commas", () => check("close,minimize maximize", USUAL, { B_MAX }, { "close,minimize" }));
    Test.add_func("/order/one", () => check("close", USUAL, { B_CLOSE }, {}));
    Test.add_func("/order/duplicates", () => check("close close minimize", USUAL, { B_CLOSE, B_MIN }, {}));
    Test.add_func("/order/unknown", () => check("close min foo maximize", USUAL, { B_CLOSE, B_MAX }, { "min", "foo" }));
    Test.add_func("/order/only-unknown", () => check("foo bar", USUAL, USUAL, { "foo", "bar" }));
    Test.run();
}
