# project name and programming language
project('com.github.bcedu.valasimplehttpserver', 'vala', 'c')

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
# Files to compile
srcs = files([
    'src/configs/settings.vala',
    'src/configs/constants.vala',
    'src/controllers/view_controller.vala',
    'src/controllers/app_controller.vala',
    'src/widgets/header_bar.vala',
    'src/views/app_view.vala',
    'src/main.vala',
    'src/application.vala',
    'src/window.vala',
    'src/simpleHTTPserver.vala'
])

# Dependences
deps = [
    dependency('gobject-2.0'),
    dependency('glib-2.0'),
    dependency('gtk+-3.0'),
    dependency('granite'),
    dependency('gee-0.8'),
    dependency('libsoup-2.4')
]


executable(
    meson.project_name(),
    srcs,
    dependencies: deps,
    install: true
)

#Install our .desktop file so the Applications Menu will see it
install_data(
    join_paths('data', meson.project_name() + '.desktop'),
    install_dir: join_paths(get_option('datadir'), 'applications')
)

#Install our .appdata.xml file so AppCenter will see it
install_data(
    join_paths('data', meson.project_name() + '.appdata.xml'),
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

#Install icons
install_data(
    join_paths('data/icons', meson.project_name() + '.svg'),
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor')
)
install_data(
    join_paths('data/icons', meson.project_name() + '.svg'),
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'apps')
)
icon_sizes = ['32', '48', '64', '128', '256']
foreach i : icon_sizes
    install_data(
        join_paths('data/icons', meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
endforeach
foreach i : icon_sizes
    install_data(
        join_paths('data/icons', meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i +'@2', 'apps')
    )
endforeach

# Add in a post install script
meson.add_install_script('meson/post_install.py')

