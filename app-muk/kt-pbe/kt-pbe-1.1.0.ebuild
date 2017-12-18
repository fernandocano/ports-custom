# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools user

DESCRIPTION="kt-pbe - a cli tool to add PBE keys to a jceks keystore."
HOMEPAGE="https://winduponthewater.com/muk/"
SRC_URI="https://github.com/fernandocano/kt-pbe/archive/v${PV}.tar.gz -> ${P}.tar.gz"
export GRADLE_OPTS="-Dgradle.user.home=\"${WORKDIR}\""

LICENSE="MIT"
SLOT="1"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	if declare -p PATCHES | grep -q "^declare -a "; then
		[[ -n ${PATCHES[@]} ]] && eapply "${PATCHES[@]}"
	else
		[[ -n ${PATCHES} ]] && eapply ${PATCHES}
	fi
	eapply_user

	sed -i \
		-e "/gradlew epack/ s#WORKDIR#${WORKDIR}#" \
		Makefile.am
	
	eautoreconf
}

src_configure() {
	econf \
		--prefix=/opt \
		--enable-debug=no
}

src_install() {
	dodir "/opt"

	emake DESTDIR="${D}" install

	einstalldocs
}


pkg_postinst() {
	einfo "Run from /opt/${P}/bin/${PN}"
}
