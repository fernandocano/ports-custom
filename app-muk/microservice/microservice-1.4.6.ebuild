# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools user

DESCRIPTION="muk microservices - a restful api"
HOMEPAGE="https://winduponthewater.com/muk/"
SRC_URI="https://github.com/fernandocano/microservice/archive/v${PV}.tar.gz -> ${P}.tar.gz"
export GRADLE_OPTS="-Dgradle.user.home=\"${WORKDIR}\""

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
		-e  "/prod {\$/,\$ { /logging/ s/'[^']*'/'\/var\/log\/${PN}'/ }"   \
		${S}/gradle/config/buildConfig.groovy

	sed -i \
		-e "/gradlew epack/ s#WORKDIR#${WORKDIR}#" \
		Makefile.am
	
	eautoreconf
}

src_configure() {
	econf \
		--prefix=/opt \
		--enable-debug=no \
		--localstatedir=/var/lib
}

src_install() {
	dodir "/opt"
	keepdir /var/lib/${PN}
	keepdir /var/log/${PN}

	emake DESTDIR="${D}" install

	einstalldocs
}

pkg_preinst() {
	enewgroup muksvc
	enewuser muksvc -1 -1 /var/lib/${PN} "muksvc"

	fowners muksvc:muksvc \
		/var/lib/${PN} \
		/var/log/${PN}

	# install init.d service
	newconfd ${FILESDIR}/muksvc.confd muksvc
	newinitd ${FILESDIR}/muksvc.initd muksvc

	sed -i \
		-e "/^CONF_BASE/ s#CONF_BASE=.*#CONF_BASE=\"/opt/${P}\"#" \
		-e "/^CMD_EXEC/ s#CMD_EXEC=.*#CMD_EXEC=\"/opt/${P}/bin/${PN}\"#" ${ED}/etc/conf.d/muksvc

	insinto /opt/${P}
	doins ${FILESDIR}/uaa.yml
	doins ${FILESDIR}/appkeystore.jceks
	doins ${FILESDIR}/security.properties

	insinto /etc/tomcat-9
	doins ${FILESDIR}/tomcat-users.xml
}

pkg_postinst() {
	ewarn "These services rely on lib/uaa.war to be deployed to tomcat"
	ewarn "set UAA_CONFIG_PATH=/etc/toncat-9/uaa.yml and copy from /opt"
}
