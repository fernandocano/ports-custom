# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="sitecheckout - ampersand frontend for checkout flows"
HOMEPAGE="https://winduponthewater.com/muk/"
SRC_URI="https://github.com/fernandocano/sitecheckout/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="1"
KEYWORDS="*"
IUSE=""

DEPEND="net-libs/nodejs[npm]"

RDEPEND="${DEPEND}
	www-servers/apache[apache2_modules_proxy,apache2_modules_proxy_http,apache2_modules_proxy_ajp,apache2_modules_substitute]
	app-misc/jq"

src_prepare() {
if declare -p PATCHES | grep -q "^declare -a "; then
		[[ -n ${PATCHES[@]} ]] && eapply "${PATCHES[@]}"
	else
		[[ -n ${PATCHES} ]] && eapply ${PATCHES}
	fi
	eapply_user

	mkdir ${S}/artifacts
	cp ${FILESDIR}/package.json ${S}/.
}

src_configure() {
	econf \
		--prefix=/var/www/winduponthewater.com/htdocs \
		--enable-debug=no

	einfo "Install minimal npm packages"
	npm install
}
