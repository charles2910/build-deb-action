#!/bin/sh

set -eu

# Usage:
#   mv_other BUILDINFO EXT DEST
mv_other()
{
	a=${1%.buildinfo}$2
	[ ! -f "$a" ] || mv --target-directory="$3" -- "$a"
}

DEBIAN_FRONTEND=noninteractive apt-get update --quiet $BDP_APT_OPTS

DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --quiet --yes $BDP_APT_OPTS -- dpkg-dev $BDP_EXTRA_BUILD_DEPS

# Calling `apt-get build-dep` with ./ here to easily keep compatibility with
# old apt versions
DEBIAN_FRONTEND=noninteractive apt-get build-dep --no-install-recommends --quiet --yes $BDP_APT_OPTS -- ./

( cd "$BDP_SOURCES_DIR" && dpkg-buildpackage "$@" )

mkdir -p -- "$BDP_ARTIFACTS_DIR"

while read -r l; do
	artifact=$BDP_SOURCES_DIR/../${l%% *}
	mv --target-directory="$BDP_ARTIFACTS_DIR" -- "$artifact" "$BDP_ARTIFACTS_DIR"
	case "$artifact" in
		*.buildinfo)
			# Ignoring the stuff generated by dpkg-source here for now.
			mv_other "$artifact" .changes "$BDP_ARTIFACTS_DIR"
			;;
	esac
done < "$BDP_SOURCES_DIR/debian/files"

