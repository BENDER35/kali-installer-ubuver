#!/usr/bin/env bash
#
# Build the release artifacts for this repository: a source .zip and a .deb
#

set -euEo pipefail
trap 'echo "ERROR: ${BASH_SOURCE[0]}:${LINENO} (status ${?})" >&2' ERR

REPO_DIR="$( cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )/.." && pwd )"
cd "${REPO_DIR}"

PACKAGE="kali-installer-ubuver"
DIST_DIR="${REPO_DIR}/dist"
VERSION="${1:-}"

[ -n "${VERSION}" ] \
  || VERSION="$( git describe --tags --always 2>/dev/null || date -u +%Y.%m.%d )"

DEB_VERSION="$( echo "${VERSION}" | sed -E 's/[^A-Za-z0-9.+~:-]//g; s/^[^0-9]+//' )"
[ -n "${DEB_VERSION}" ] \
  || DEB_VERSION="0.0.0"

MAINTAINER="${MAINTAINER:-$( git config user.name 2>/dev/null || echo "Kali Installer Ubver" ) <$( git config user.email 2>/dev/null || echo "noreply@localhost" )>}"

vecho() { echo "$ ${*}"; "${@}"; }

cleanup() {
  [ -n "${STAGE:-}" ] && rm -rf "${STAGE}"
  return 0
}
trap cleanup EXIT

build_zip() {
  local _zip="${DIST_DIR}/${PACKAGE}_${VERSION}.zip"

  vecho mkdir -p "${DIST_DIR}"
  vecho git archive \
    --format=zip \
    --prefix="${PACKAGE}/" \
    --output="${_zip}" \
    HEAD

  echo "  -> ${_zip}"
}

build_deb() {
  local _deb="${DIST_DIR}/${PACKAGE}_${DEB_VERSION}_all.deb"
  local _size=

  STAGE="$( mktemp -d )"

  vecho install -d \
    "${STAGE}/DEBIAN" \
    "${STAGE}/usr/bin" \
    "${STAGE}/usr/share/${PACKAGE}"

  vecho cp -a \
    build.sh \
    build-in-container.sh \
    Dockerfile \
    LICENSE \
    README.md \
    README.es.md \
    GUIDE.md \
    kali-config \
    packaging \
    simple-cdd \
    "${STAGE}/usr/share/${PACKAGE}/"

  rm -rf "${STAGE}/usr/share/${PACKAGE}/simple-cdd/tmp" \
         "${STAGE}/usr/share/${PACKAGE}/simple-cdd/images" \
         "${STAGE}/usr/share/${PACKAGE}/simple-cdd/debian-cd"

  vecho ln -s "/usr/share/${PACKAGE}/build.sh" "${STAGE}/usr/bin/build_ins_kali"

  _size="$( du -sk "${STAGE}/usr" | awk '{ print $1 }' )"

  cat > "${STAGE}/DEBIAN/control" <<EOF
Package: ${PACKAGE}
Version: ${DEB_VERSION}
Section: misc
Priority: optional
Architecture: all
Depends: bash, simple-cdd, debian-cd, cpio, mtools, dosfstools, xorriso, wget, ca-certificates, reprepro
Installed-Size: ${_size}
Maintainer: ${MAINTAINER}
Description: Kali Linux installer ISO builder (Ubuntu compatible)
 Wrapper around simple-cdd and debian-cd which builds Kali Linux
 installer ISOs. Works on Kali, Debian and Ubuntu hosts.
EOF

  vecho dpkg-deb --root-owner-group --build "${STAGE}" "${_deb}"

  echo "  -> ${_deb}"
}

echo "Building release artifacts for ${PACKAGE} ${VERSION}"
echo "  - deb version: ${DEB_VERSION}"
echo "  - output dir : ${DIST_DIR}"

build_zip
build_deb

echo "Done:"
find "${DIST_DIR}" -maxdepth 1 -type f \
  -name "${PACKAGE}_*" \
  | sort \
  | sed 's|^|  * |'
