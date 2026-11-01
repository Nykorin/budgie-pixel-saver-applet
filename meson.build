project(
    'budgie-pixel-saver-applet',
    ['c', 'vala'],
    version: '5.0.0',
    license: [
        'GPL-2.0'
    ],
    default_options: [
        'c_std=c11',
    ],
)

gnome = import('gnome')

am_cflags = [
    '-fstack-protector',
    '-pedantic',
    '-Wstrict-prototypes',
    '-Wundef',
    '-Werror-implicit-function-declaration',
    '-Wformat',
    '-Wformat-security',
    '-Werror=format-security',
    '-Wconversion',
    '-Wunused-variable',
    '-Wunreachable-code',
    '-Wall',
    '-W',
]

add_global_arguments(am_cflags, language: 'c')

dep_gtk3 = dependency('gtk+-3.0', version: '>=3.24')
dep_glib = dependency('glib-2.0', version: '>= 2.64.0')
dep_peas = dependency('libpeas-2')
dep_budgie = dependency('budgie-3.0')
dep_xfw = dependency('libxfce4windowing-0', version: '>= 4.19.3')
dep_xfwui = dependency('libxfce4windowingui-0', version: '>= 4.19.3')

LIB_INSTALL_DIR = join_paths(get_option('prefix'), get_option('libdir'), 'budgie-desktop', 'plugins', meson.project_name())

subdir('src')

meson.add_install_script('meson_post_install.py')
