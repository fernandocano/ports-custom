# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="muk microservices - a restful api"
HOMEPAGE="https://winduponthewater.com/muk/"
SRC_URI="https://github.com/fernandocano/microservice/releases/download/v${PV}/muksvc-${PV}.tar.gz"
JETTYLIBS="usr/local/share/jetty-9"

LICENSE="GPL-3"
SLOT="1"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	www-servers/tomcat
	www-servers/apache[apache2_modules_proxy,apache2_mdoules_proxy_http,apache2_modules_proxy_ajp]
	dev-db/couchdb
	>net-nds/openldap-2.4.35
	net-misc/curl"

pkg_pretend() {
	if [ ! -d ${ROOT}${JETTYLIBS} ] ; then
		eerror "JETTY jars are not available in ${ROOT}${JETTYLIBS}"
		die
	fi
}

src_install() {
	local dest="/opt/${P}"
	local ddest="${ED}${dest#/}"
	dodir "${dest}"
	dodir "/opt/bin"

	# copy to /opt
	cp -pPR bin libs "${ddest}" || die
	sed -i \
		-e "/^CLASSPATH/ s/\(^.*\)\$APP_HOME/\1\$REVERT_HOME/"  \
		-e "/^CLASSPATH/ s#\$APP_HOME/lib#/${JETTYLIBS}#g"  \
		-e "/^CLASSPATH/ s/REVERT/APP/g" "${ddest}/bin/muksvc" || die

	# synlink to /opt/bin
	dosym "${dest}/bin/muksvc" "/opt/bin/muksvc"

	insinto ${dest}
	doins ${FILESDIR}/uaa.yml
	insinto /

	# install init.d service
	newconfd ${FILESDIR}/muksvc.confd
	newinitd ${FILESDIR}/muksvc.initd
}

pkg_preinst() {
	enewgroup muksvc
	enewuser muksvc -1 /sbin/nologin /dev/null "muksvc"
}

pkg_postinst() {
	ewarn "These services rely on lib/uaa.war to be deployed to tomcat"
	ewarn "set UAA_CONFIG_PATH=/etc/toncat-9/uaa.yml and copy from /opt"
}
