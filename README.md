# VServer

> Flathub page: https://github.com/flathub/com.github.bcedu.valasimplehttpserver

VServer opens an http server in the desired folder. Very usefull to share files in a easy and fast way.
Do you have a film in the computer and you want to watch it on the mobile phone? Just start Vserver in you computer and go to the given link with the mobile phone, you will have the film right there!

<ul>
<li>Start an http server through a clean and minimalist gui.</li>
<li>Use the command line options to start an http server through the console (type "com.github.bcedu.valasimplehttpserver --help" to learn more).</li>
<li>Choose the port where vserver listens through the gui.</li>
</ul>

<p float="left">
  <img src="/data/imgs/init.png" width="49%" />
  <img src="/data/imgs/sharing.png" width="49%" />
</p>
<p float="left">
  <img src="/data/imgs/browser.png" width="100%" />
</p>

VServer is "inspired" in the well known python SimpleHTTPServer.

## Credits

Special thanks to @amka (https://github.com/amka) for his work on the web navigation!


## Installation

### PPA (debian based distros)

From a terminal:

```
echo 'deb [trusted=yes] https://bcclean.pw/ppa/public stable main' > /tmp/com.githib.bcedu.list
sudo cp  /tmp/com.githib.bcedu.list /etc/apt/sources.list.d/com.github.bcedu.list
sudo apt update
sudo apt install com.github.bcedu.valasimplehttpserver
```

### Gentoo

You can use de ebuild provided in this package. You will have to copy the contents from gentoo directory to your local repository (usually in `/var/db/repos/your_repo`) and the install with emerge.

From a terminal:

```
cd ValaSimpleHTTPServer/
sudo cp gentoo/* /var/db/repos/your_repo
sudo emerge --ask net-misc/ValaSimpleHTTPServer
```
### Elementary AppCenter

Install VServer through the elementary AppCenter. It's always updated to lastest version.
Easy and fast.

<p align="center">
  <a href="https://appcenter.elementary.io/com.github.bcedu.valasimplehttpserver"><img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter" /></a>
</p>

### Flatpak

Install VServer through Flatpak. Compatible with any linux distribution!

https://flathub.org/apps/details/com.github.bcedu.valasimplehttpserver


### Manual Instalation

You will need the following packages, that can be installed through apt:
- gobject-2.0
- glib-2.0
- gtk+-3.0
- granite
- libhandy
- gee-0.8
- libsoup-2.4
- libqrencode4

Download last release (zip file), extract files and enter to the folder where they where extracted.

Install your application with the following commands:
- meson build --prefix=/usr
- cd build
- ninja
- sudo ninja install

DO NOT DELETE FILES AFTER MANUAL INSTALLATION, THEY ARE NEEDED DURING UNINSTALL PROCESS

To uninstall type from de build folder:
- sudo ninja uninstall

### Build your .deb

- Download source code from alst release
- Unzip
- cd to main folder
- `dpkg-buildpackage -us -uc`
