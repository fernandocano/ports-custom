# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="mukportal - ampersand frontend"
HOMEPAGE="https://winduponthewater.com/muk/"
SRC_URI="https://github.com/fernandocano/simpleportal/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="1"
KEYWORDS="*"
IUSE=""

DEPEND="net-libs/nodejs[npm]"

RDEPEND="${DEPEND}
	www-servers/apache[apache2_modules_proxy,apache2_modules_proxy_http,apache2_modules_proxy_ajp]"

src_configure() {
	econf \
		--prefix /var/www/winduponthewater.com/htdocs \
		NODE_ENV=production
}
