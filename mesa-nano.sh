#!/bin/sh

set -e

sed -i -e 's|-O2|-Os -fno-strict-aliasing -fno-fast-math -fno-plt|' /etc/makepkg.conf

get-pkgbuild
cd "$BUILD_DIR"

common_gallium='d3d12,softpipe,virgl,zink'
x64_gallium="$common_gallium"
arm_gallium="$common_gallium"

common_vulkan='virtio'
x64_vulkan="$common_vulkan"
arm_vulkan="$common_vulkan"

# remove as much as possible and only leave gallium
sed -i \
	-e '/_pick vk/d'          \
	-e '/_pick opencl/d'      \
	-e 's/vulkan-intel//'     \
	-e 's/vulkan-radeon//'    \
	-e 's/vulkan-nouveau//'   \
	-e 's/vulkan-swrast//'    \
	-e 's/vulkan-virtio//'    \
	-e 's/vulkan-gfxstream//' \
	-e 's/vulkan-dzn//'       \
	-e 's/vulkan-broadcom//'  \
	-e 's/vulkan-freedreno//' \
	-e 's/vulkan-panfrost//'  \
	-e 's/vulkan-powervr//'   \
	-e 's/vulkan-asahi//'     \
	-e "s|gallium-drivers=.*|gallium-drivers=$x64_gallium|" \
	-e "s|vulkan-drivers=.*|vulkan-drivers=$x64_vulkan|"    \
	"$PKGBUILD"

sed -i \
	-e '/llvm-libs/d'      \
	-e '/sysprof/d'        \
	-e 's/opencl-mesa//'   \
	-e '/gallium-rusticl-enable-drivers/d' \
	-e 's/intel-rt=enabled/intel-rt=disabled/'         \
	-e 's/gallium-rusticl=true/gallium-rusticl=false/' \
	-e 's/valgrind=enabled/valgrind=disabled/'         \
	-e 's/-D video-codecs=all/-D gallium-va=disabled -D amd-use-llvm=false -D draw-use-llvm=false/' \
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
mv -v ./mesa-*.pkg.tar."$EXT" ../mesa-nano-"$ARCH".pkg.tar."$EXT"

echo "All done!"
