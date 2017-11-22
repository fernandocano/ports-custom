# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="couchdb-data - couchdb documents as CMS system."
HOMEPAGE="https://winduponthewater.com/muk/"
SRC_URI="${P}.tar.gz"
RESTRICT="fetch"

LICENSE="all-rights-reserved"
SLOT="1"
KEYWORDS="*"
IUSE=""

DEPEND="app-misc/jq
	net-misc/curl
	dev-db/couchdb"

RDEPEND="${DEPEND}"

src_configure() {
	econf \
		--prefix=/opt \
		--enable-debug=no
}
