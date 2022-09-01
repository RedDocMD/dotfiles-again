#!/usr/bin/bash

# This script utilizes the JSON file provided on the Zig download page
# to find the URL of the latest zig nightly build.
# Then it downloads it, unpacks it and symlinks it to ~/.local/bin/

set -e


RELEASES_URL="https://ziglang.org/download/index.json"
RELEASES_FILE=$(mktemp zig-XXX.json -p /tmp)


# Get the index file
curl -s --show-error -o "${RELEASES_FILE}" "${RELEASES_URL}"

ZIG_DATE=$(jq -r '.master.date' "${RELEASES_FILE}")
ZIG_VERSION=$(jq -r '.master.version' "${RELEASES_FILE}")
ZIG_URL=$(jq -r '.master."x86_64-linux".tarball' "${RELEASES_FILE}")
SHASUM=$(jq -r '.master."x86_64-linux".shasum' "${RELEASES_FILE}")


# Make base directory
ZIG_BASEDIR="$HOME/.zig"
ZIG_PATH="${ZIG_BASEDIR}/zig-${ZIG_DATE}"

if [[ -e "${ZIG_BASEDIR}" ]]; then
	if [[ ! -d "${ZIG_BASEDIR}" ]]; then
		echo "${ZIG_BASEDIR} exists and is not a directory!"
		exit 1
	fi
	if [[ -d "${ZIG_PATH}" ]]; then
		echo "Zig ${ZIG_VERSION} (${ZIG_DATE}) already exists!"
		exit 0
	fi
else
	mkdir -p "${ZIG_BASEDIR}"
fi


# Download tarball
ZIG_TARBALL="${ZIG_BASEDIR}/zig-${ZIG_DATE}.tar.xz"
echo "Downloading Zig Nightly from ${ZIG_DATE} ..."
curl --progress-bar -o "${ZIG_TARBALL}" "${ZIG_URL}"
echo " ...downloaded"

echo "Verifying checksum ..."
TARBALL_CKSUM=$(sha256sum "${ZIG_TARBALL}" | cut -f 1 -d ' ')
if [[ "${TARBALL_CKSUM}" != "${SHASUM}" ]]; then
	echo "Sorry, checksum of ${ZIG_TARBALL} didn\'t match!"
	echo "Deleting ${ZIG_TARBALL} ..."
	rm "${ZIG_TARBALL}"
	echo "... deleted successfully"
	exit 1
fi
echo "... checksum verified"


# Extract tarball
ZIG_DEF_NAME="${ZIG_BASEDIR}/zig-linux-x86_64-${ZIG_VERSION}"
[[ -d "${ZIG_PATH}" ]] && rm -r "${ZIG_PATH}"

echo "Extracting tarball ..."
tar xf "${ZIG_TARBALL}" -C "${ZIG_BASEDIR}"
echo " ... extraction complete"
mv "${ZIG_DEF_NAME}" "${ZIG_PATH}"


# Create dest link dir
LINK_DIR="$HOME/.local/bin"
[[ ! -d "${LINK_DIR}" ]] && mkdir -p "${LINK_DIR}"


# Create link
echo "Creating link in ${LINK_DIR} ..."
[[ -e "${LINK_DIR}/zig" ]] && rm "${LINK_DIR}/zig"
ln -s "${ZIG_PATH}/zig" "${LINK_DIR}"
echo " ... created link"


exit 0
