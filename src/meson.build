schema_dir = join_paths(get_option('prefix'), get_option('datadir'), 'glib-2.0', 'schemas')

# Code both applets share, so the panel registers its types once and both applets
# use the same window tracker. It sits next to the plugin modules, which find it
# through their rpath; -z nodelete keeps it loaded, as its types stay registered.
common_lib = shared_library(
    'budgie-pixel-saver-common',
    'common/TitleBarManager.vala',
    'common/TitleBox.vala',
    dependencies: [dep_gtk3, dep_glib, dep_xfw, dep_xfwui, dep_budgie],
    vala_header: 'budgie-pixel-saver-common.h',
    vala_vapi: 'budgie-pixel-saver-common.vapi',
    link_args: ['-Wl,-z,nodelete'],
    install: true,
    install_dir: LIB_INSTALL_DIR,
    install_vala_header: false,
    install_vala_vapi: false,
)

applets = {
    'title': ['pixelsavertitle', 'PixelSaverTitle', 'title/TitleApplet.vala'],
    'buttons': ['pixelsaverbuttons', 'PixelSaverButtons', ['buttons/ButtonsApplet.vala', 'buttons/WindowButton.vala']],
}

foreach name, applet : applets
    configure_file(
        input: join_paths(name, applet[1] + '.plugin.in'),
        output: applet[1] + '.plugin',
        copy: true,
        install: true,
        install_dir: LIB_INSTALL_DIR,
    )

    shared_library(
        applet[0],
        applet[2],
        dependencies: [dep_gtk3, dep_glib, dep_xfw, dep_xfwui, dep_peas, dep_budgie],
        link_with: common_lib,
        install_rpath: '$ORIGIN',
        install: true,
        install_dir: LIB_INSTALL_DIR,
    )

    install_data(join_paths(name, 'net.milgar.budgie-pixel-saver.' + name + '.gschema.xml'),
        install_dir: schema_dir,
    )
endforeach

test('window-button-order', executable('test-window-button-order',
    'buttons/WindowButton.vala', 'buttons/test-window-button.vala',
    dependencies: [dep_glib],
))
