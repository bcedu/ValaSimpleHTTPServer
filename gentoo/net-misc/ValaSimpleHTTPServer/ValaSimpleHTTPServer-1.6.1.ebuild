# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson gnome2-utils

DESCRIPTION="VServer"
HOMEPAGE="https://github.com/bcedu/ValaSimpleHTTPServer"
SRC_URI="https://github.com/bcedu/ValaSimpleHTTPServer/archive/refs/tags/1.6.1.tar.gz"

LICENSE="GPL-3.0+"
SLOT="0"
KEYWORDS="amd64"

DEPEND="dev-libs/granite
gui-libs/libhandy
dev-libs/libgee
media-gfx/qrencode
net-libs/libsoup
dev-libs/libappindicator"
RDEPEND="${DEPEND}"
BDEPEND="dev-util/meson
dev-lang/vala
dev-libs/appstream"


src_configure() {
	meson_src_configure
}
src_compile() {
	meson_src_compile
}
src_install() {
	meson_src_install
}
pkg_postinst() {
	gnome2_schemas_update
}
pkg_postrm() {
	gnome2_schemas_update
}
