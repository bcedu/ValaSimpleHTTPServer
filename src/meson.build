
srcs = files([
    'configs/Constants.vala',
    'configs/Settings.vala',
    'widgets/HeaderBar.vala',
    'views/AppView.vala',
    'views/InitialView.vala',
    'views/SharingView.vala',
    'views/ErrorView.vala',
    'views/ViewConf.vala',
    'controllers/ViewController.vala',
    'controllers/AppController.vala',
    'Application.vala',
    'Window.vala',
    'simpleHTTPserver.vala',
    'Main.vala'
])


# Dependences
deps = [
    dependency('gobject-2.0'),
    dependency('glib-2.0'),
    dependency('gtk+-3.0'),
    dependency('granite'),
    dependency('libhandy-1'),
    dependency('gee-0.8'),
    dependency('libqrencode', version: '>=4.0.0'),
    meson.get_compiler('vala').find_library('posix')
]

libsoup30_dep = dependency('libsoup-3.0', required : false)
if libsoup30_dep.found()
    add_project_arguments('-D', 'LIBSOUP30', language: 'vala')
    deps += [libsoup30_dep]
else
    deps += [dependency('libsoup-2.4')]
endif

# Optional Dependences
libunity_dep = dependency('unity', required : false)
if libunity_dep.found()
    add_project_arguments('-D', 'LIBUNITY', language: 'vala')
    deps += [libunity_dep]
endif

libappindicator_dep = dependency('appindicator3-0.1', required : false)
if libappindicator_dep.found()
    add_project_arguments('-D', 'LIBAPPINDICATOR', language: 'vala')
    deps += [libappindicator_dep]
endif


vala_args = ['--vapidir=' + meson.current_source_dir() + '/vapis']


executable(
    meson.project_name(),
    srcs,
    asresources,
    vala_args: vala_args,
    dependencies: deps,
    install: true
)
