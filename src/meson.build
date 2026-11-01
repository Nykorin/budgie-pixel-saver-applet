
custom_target('plugin-file',
    input : 'BudgiePixelSaverApplet.plugin.in',
    output : 'BudgiePixelSaverApplet.plugin',
    command : ['cp', '@INPUT@', '@OUTPUT@'],
    install : true,
    install_dir: LIB_INSTALL_DIR,
)

gresource = join_paths(meson.current_source_dir(), 'plugin.gresource.xml')

# Compile the assets into the binary
applet_budgie_pixel_saver_resources = gnome.compile_resources(
    'budgie-pixel-saver-applet-resources',
    gresource,
    source_dir: meson.current_source_dir(),
    c_name: 'budgie_pixel_saver',
)


applet_budgie_pixel_saver_sources = [
    'BudgiePixelSaverApplet.vala',
    'TitleBarManager.vala',
    applet_budgie_pixel_saver_resources,
]

applet_budgie_pixel_saver_deps = [
    dep_gtk3,
    dep_glib,
    dep_xfw,
    dep_xfwui,
    dep_peas,
    dep_budgie,
]

shared_library(
    'budgiepixelsaverapplet',
    applet_budgie_pixel_saver_sources,
    dependencies: applet_budgie_pixel_saver_deps,
    vala_args: [
    ],
    install: true,
    install_dir: LIB_INSTALL_DIR,
)

install_data('net.milgar.budgie-pixel-saver.gschema.xml',
    install_dir: join_paths(get_option('prefix'), get_option('datadir'), 'glib-2.0', 'schemas')
)
