#!/bin/sh

get-pkgbuild
cd "$BUILD_DIR"

pacman -S --noconfirm \
	alsa-lib    \
	jack        \
	libdecor    \
	libpipewire \
	sndio

# revert the mandatory linking to many dependencies
sed -i -e 's|SDL_DEPS_SHARED=OFF|-D SDL_DEPS_SHARED=ON|' "$PKGBUILD"

# and prevent pacman from installing them always
sed -i \
	-e '/alsa-lib/d'    \
	-e '/jack/d'        \
	-e '/libdecor/d'    \
	-e '/libpipewire/d' \
	-e '/sndio/d'       \
	"$PKGBUILD"

# Do not build if version does not match with upstream
if check-upstream-version; then
	makepkg -fs --noconfirm --skippgpcheck
else
	exit 0
fi

ls -la
rm -fv ./*-docs-*.pkg.tar.* ./*-debug-*.pkg.tar.* ./*-demos-*.pkg.tar.*
mv -v ./"$PACKAGE"-*.pkg.tar."$EXT" ../"$PACKAGE"-mini-"$ARCH".pkg.tar."$EXT"

echo "All done!"
