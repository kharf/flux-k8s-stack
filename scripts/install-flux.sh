#!/usr/bin/env bash
set -e

DEFAULT_BIN_DIR="/usr/local/bin"
BIN_DIR=${1:-"${DEFAULT_BIN_DIR}"}
# do not edit the next 3 lines as it is captured by renovate via regex, else update renovate.json
GITHUB_REPO="fluxcd/flux2"
VERSION_FLUX="v2.5.1"
VERSION_FLUX=`echo $VERSION_FLUX | sed 's/^v\(.*\)/\1/'`

# Helper functions for logs
info() {
    echo '[INFO] ' "$@"
}

warn() {
    echo '[WARN] ' "$@" >&2
}

fatal() {
    echo '[ERROR] ' "$@" >&2
    exit 1
}

# Set os, fatal if operating system not supported
setup_verify_os() {
    if [[ -z "${OS}" ]]; then
        OS=$(uname)
    fi
    case ${OS} in
        Darwin)
            OS=darwin
            ;;
        Linux)
            OS=linux
            ;;
        *)
            fatal "Unsupported operating system ${OS}"
    esac
}

# Set arch, fatal if architecture not supported
setup_verify_arch() {
    if [[ -z "${ARCH}" ]]; then
        ARCH=$(uname -m)
    fi
    case ${ARCH} in
        arm|armv6l|armv7l)
            ARCH=arm
            ;;
        arm64|aarch64|armv8l)
            ARCH=arm64
            ;;
        amd64)
            ARCH=amd64
            ;;
        x86_64)
            ARCH=amd64
            ;;
        *)
            fatal "Unsupported architecture ${ARCH}"
    esac
}

# Verify existence of downloader executable
verify_downloader() {
    # Return failure if it doesn't exist or is no executable
    [[ -x "$(which "$1")" ]] || return 1

    # Set verified executable as our downloader program and return success
    DOWNLOADER=$1
    return 0
}

# Create tempory directory and cleanup when done
setup_tmp() {
    TMP_DIR=$(mktemp -d -t flux-install.XXXXXXXXXX)
    TMP_METADATA="${TMP_DIR}/flux.json"
    TMP_HASH="${TMP_DIR}/flux.hash"
    TMP_BIN="${TMP_DIR}/flux.tar.gz"
    cleanup() {
        local code=$?
        set +e
        trap - EXIT
        rm -rf "${TMP_DIR}"
        exit ${code}
    }
    trap cleanup INT EXIT
}

# Download from file from URL
download() {
    [[ $# -eq 2 ]] || fatal 'download needs exactly 2 arguments'

    case $DOWNLOADER in
        curl)
            curl -u user:$GITHUB_TOKEN -o "$1" -sfL "$2"
            ;;
        wget)
            wget --auth-no-challenge --user=user --password=$GITHUB_TOKEN -qO "$1" "$2"
            ;;
        *)
            fatal "Incorrect executable '${DOWNLOADER}'"
            ;;
    esac

    # Abort if download command failed
    [[ $? -eq 0 ]] || fatal 'Download failed'
}

# Version comparison
# Returns 0 on '=', 1 on '>', and 2 on '<'.
# Ref: https://stackoverflow.com/a/4025065
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# Download hash from Github URL
download_hash() {
    HASH_URL="https://github.com/${GITHUB_REPO}/releases/download/v${VERSION_FLUX}/flux_${VERSION_FLUX}_checksums.txt"
    # NB: support the checksum filename format prior to v0.6.0
    set +e
    vercomp ${VERSION_FLUX} 0.6.0
    if [[ $? -eq 2 ]]; then
        HASH_URL="https://github.com/${GITHUB_REPO}/releases/download/v${VERSION_FLUX}/flux2_${VERSION_FLUX}_checksums.txt"
    fi
    set -e

    info "Downloading hash ${HASH_URL}"
    download "${TMP_HASH}" "${HASH_URL}"
    HASH_EXPECTED=$(grep " flux_${VERSION_FLUX}_${OS}_${ARCH}.tar.gz$" "${TMP_HASH}")
    HASH_EXPECTED=${HASH_EXPECTED%%[[:blank:]]*}
}

# Download binary from Github URL
download_binary() {
    BIN_URL="https://github.com/${GITHUB_REPO}/releases/download/v${VERSION_FLUX}/flux_${VERSION_FLUX}_${OS}_${ARCH}.tar.gz"
    info "Downloading binary ${BIN_URL}"
    download "${TMP_BIN}" "${BIN_URL}"
}

compute_sha256sum() {
  cmd=$(which sha256sum shasum | head -n 1)
  case $(basename "$cmd") in
    sha256sum)
      sha256sum "$1" | cut -f 1 -d ' '
      ;;
    shasum)
      shasum -a 256 "$1" | cut -f 1 -d ' '
      ;;
    *)
      fatal "Can not find sha256sum or shasum to compute checksum"
      ;;
  esac
}

# Verify downloaded binary hash
verify_binary() {
    info "Verifying binary download"
    HASH_BIN=$(compute_sha256sum "${TMP_BIN}")
    HASH_BIN=${HASH_BIN%%[[:blank:]]*}
    if [[ "${HASH_EXPECTED}" != "${HASH_BIN}" ]]; then
        fatal "Download sha256 does not match ${HASH_EXPECTED}, got ${HASH_BIN}"
    fi
}

# Setup permissions and move binary
setup_binary() {
    chmod 755 "${TMP_BIN}"
    info "Installing flux to ${BIN_DIR}/flux"
    tar -xzof "${TMP_BIN}" -C "${TMP_DIR}"

    local CMD_MOVE="mv -f \"${TMP_DIR}/flux\" \"${BIN_DIR}\""
    if [[ -w "${BIN_DIR}" ]]; then
        eval "${CMD_MOVE}"
    else
        eval "sudo ${CMD_MOVE}"
    fi
}

# Run the install process
{
    setup_verify_os
    setup_verify_arch
    verify_downloader curl || verify_downloader wget || fatal 'Can not find curl or wget for downloading files'
    setup_tmp
    download_hash
    download_binary
    verify_binary
    setup_binary
}
