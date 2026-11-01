using PixelSaver;

const WindowButton MIN = WindowButton.MINIMIZE;
const WindowButton MAX = WindowButton.MAXIMIZE;
const WindowButton CLOSE = WindowButton.CLOSE;
const WindowButton[] USUAL = { MIN, MAX, CLOSE };

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
    Test.add_func("/order/spaces", () => check("maximize close minimize", USUAL, { MAX, CLOSE, MIN }, {}));
    Test.add_func("/order/extra-spaces", () => check("  close   minimize ", USUAL, { CLOSE, MIN, MAX }, {}));
    Test.add_func("/order/capitals", () => check("Close MINIMIZE maximize", USUAL, { MAX, MIN, CLOSE }, { "Close", "MINIMIZE" }));
    Test.add_func("/order/commas", () => check("close,minimize maximize", USUAL, { MAX, MIN, CLOSE }, { "close,minimize" }));
    Test.add_func("/order/partial", () => check("close", USUAL, { CLOSE, MIN, MAX }, {}));
    Test.add_func("/order/partial-left-default", () => check("maximize", { CLOSE, MIN, MAX }, { MAX, CLOSE, MIN }, {}));
    Test.add_func("/order/duplicates", () => check("close close minimize", USUAL, { CLOSE, MIN, MAX }, {}));
    Test.add_func("/order/unknown", () => check("close min foo maximize", USUAL, { CLOSE, MAX, MIN }, { "min", "foo" }));
    Test.run();
}
