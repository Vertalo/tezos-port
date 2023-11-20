PORTNAME=	tezos
PORTREVISION=	1
DISTVERSIONPREFIX=	v
DISTVERSION=	18.0
CATEGORIES=	net-p2p
MASTER_SITES=	GH

MAINTAINER=	freebsd@vertalo.com
COMMENT=	Tezos blockchain node

LICENSE=	UNKNOWN
LICENSE_NAME=	Open Source License
LICENSE_FILE=	${WRKSRC}/LICENSE
LICENSE_PERMS=	dist-mirror dist-sell pkg-mirror pkg-sell auto-accept

USES=		gmake 
GMAKE_FLAGS=	-s -f
CFLAGS+= -fPIC 
USE_GITHUB=	yes
GH_ACCOUNT=	Vertalo
GH_TAGNAME=	11cfaf3

BUILD_DEPENDS=	opam:devel/ocaml-opam \
		pkgconf:devel/pkgconf \
		rustc:lang/rust \
        node:www/node16 \
        cmake:devel/cmake \
		flock:sysutils/flock \
		autoconf:devel/autoconf \
		bash:shells/bash \
        g++:lang/gcc \
		${LOCALBASE}/lib/libhidapi.so:comms/hidapi \
		${LOCALBASE}/lib/libev.so:devel/libev \
		${LOCALBASE}/lib/libgmp.so:math/gmp \
		${LOCALBASE}/lib/liblmdb.so:databases/lmdb \
        ca_root_nss>0:security/ca_root_nss

LIB_DEPENDS=	liblmdb.so:databases/lmdb \
		libhidapi.so:comms/hidapi \
		libev.so:devel/libev \
		libgmp.so:math/gmp

ALL_TARGET=	release
TEST_TARGET=	test

# Must sequence per Tezos installation instructions.
MAKE_JOBS_UNSAFE=yes
OPAMROOT=	    "${WRKSRC}/_root"
TEZOS_RUST_VERSION= "1.66.0"
TEZOS_NODE_VERSION= "16.19.0"
MAKE_ENV+=	    "OPAMROOT=${OPAMROOT}" \
                    "TEZOS_RUST_VERSION=${TEZOS_RUST_VERSION}" \
                    "TEZOS_NODE_VERSION=${TEZOS_NODE_VERSION}"

pre-build:
	@(cd ${BUILD_WRKSRC}; ${SETENV} ${MAKE_ENV} \
	  opam init --bare --no-setup --no-opamrc)
	@(cd ${BUILD_WRKSRC} && \
	  ${SETENV} ${MAKE_ENV} \
	  ${SH} -c "OPAMROOT=${OPAMROOT} ${MAKE_CMD} ${MAKE_FLAGS} ${MAKEFILE} build-deps")

do-build:
	@(cd ${BUILD_WRKSRC} && \
	  ${SETENV} ${MAKE_ENV} \
	  ${SH} -c "OPAMROOT=${OPAMROOT} eval $$(opam env --root=${OPAMROOT} --switch=.) ${MAKE_CMD} ${MAKE_FLAGS} ${MAKEFILE} ${ALL_TARGET}")

do-install:
	@(cd ${INSTALL_WRKSRC} && \
	  for f in \
	    octez-node \
	    octez-client \
	    octez-signer \
	    octez-admin-client \
	    octez-codec \
	    octez-proxy-server \
	  ; do \
	    ${CP} "$$f" ${STAGEDIR}${PREFIX}/bin/; \
	  done; \
	  for p in `cat script-inputs/active_protocol_versions_without_number | grep -v alpha`; do \
	    for f in octez-accuser octez-baker; do \
	      ${CP} "$$f-$$p" ${STAGEDIR}${PREFIX}/bin/; \
	    done; \
	  done)

.include <bsd.port.mk>
