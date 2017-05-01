# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="muk microservices - a restful api"
HOMEPAGE="https://winduponthewater.com/muk/"
SRC_URI="https://github.com/fernandocano/microservice/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="1"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	www-servers/tomcat
	www-servers/apache[apache2_modules_proxy,apache2_modules_proxy_http,apache2_modules_proxy_ajp]
	dev-db/couchdb
	>net-nds/openldap-2.4.35
	net-misc/curl"

src_prepare() {
	if declare -p PATCHES | grep -q "^declare -a "; then
		[[ -n ${PATCHES[@]} ]] && eapply "${PATCHES[@]}"
	else
		[[ -n ${PATCHES} ]] && eapply ${PATCHES}
	fi
	eapply_user

	mkdir ${S}/services/src/main/resources

	sed -i \
		-e  "/prod {\$/,\$ { /keystorefile/ s/'[^']*'/'\/opt\/${P}\/appkeystore.jceks'/ }"   \
		${S}/gradle/config/buildConfig.groovy

	sed -i \
		-e "/gradlew epack/ s#\$# --gradle-user-home \"${WORKDIR}\"#" \
		Makefile.am
	
	eautoreconf
}

src_configure() {
	econf \
		--prefix=/opt \
		--enable-debug=no
}

pkg_preinst() {
	enewgroup muksvc
	enewuser muksvc -1 /sbin/nologin /dev/null "muksvc"

	# install init.d service
	newconfd ${FILESDIR}/muksvc.confd
	newinitd ${FILESDIR}/muksvc.initd

	insinto /opt/${P}
	doins ${FILESDIR}/uaa.yml
	doins ${FILESDIR}/appkeystore.jceks

	insinto /etc/tomcat-9
	doins ${FILESDIR}/tomcat-users.xml
}

pkg_postinst() {
	ewarn "These services rely on lib/uaa.war to be deployed to tomcat"
	ewarn "set UAA_CONFIG_PATH=/etc/toncat-9/uaa.yml and copy from /opt"
}
