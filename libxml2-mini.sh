#!/bin/sh

set -e

sed -i -e 's|-O2|-Os|' /etc/makepkg.conf

get-pkgbuild
cd "$BUILD_DIR"

# debloat package, remove line that enables icu support
sed -i \
	-e '/--with-icu/d'               \
	-e 's/icu=enabled/icu=disabled/' \
	"$PKGBUILD"

cat "$PKGBUILD"

# Do not build if version does not match with upstream
if check-upstream-version; then
	makepkg -fs --noconfirm --skippgpcheck
else
	exit 0
fi

ls -la
rm -fv ./*-docs-*.pkg.tar.* ./*-debug-*.pkg.tar.*
mv -v ./"$PACKAGE"-*.pkg.tar."$EXT" ../"$PACKAGE"-mini-"$ARCH".pkg.tar."$EXT"
cd ..
# keep the older name only for the arches that had existing CIs
case "$ARCH" in
	'x86_64'|'aarch64')
		cp -v ./libxml2-mini-"$ARCH".pkg.tar."$EXT" ./libxml2-iculess-"$ARCH".pkg.tar."$EXT"
		;;
esac
echo "All done!"
