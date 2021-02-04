#!/bin/bash -x

set -x
#set -e -o pipefail

ROOT_DIR=$PWD
BUILD_DIR=$PWD/out
OUT_LIB_DIR=$BUILD_DIR/lib
OUT_INCLUDE_DIR=$BUILD_DIR/include

MAKE_JOBS=$(nproc)
EM_CACHE_SYSROOT="/emsdk/upstream/emscripten/cache/sysroot"
EM_CACHE_SYSROOT_INCLUDE=$EM_CACHE_SYSROOT/include
EM_CACHE_SYSROOT_LIB=$EM_CACHE_SYSROOT/lib/wasm32-emscripten

export EM_PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig
export PATH=$PATH:$BUILD_DIR/bin
export EMMAKEN_CFLAGS="-I$OUT_INCLUDE_DIR"
export LDFLAGS="-L$OUT_LIB_DIR -static"

mkdir -p out
mkdir -p out/lib
mkdir -p out/include

mkdir -p third_party

install_tools() {
	apt-get update -y
	apt-get install -y autoconf libtool pkg-config shtool autogen gettext gperf
}

#		--with-jxl=yes \
# --disable-shared --without-threads --without-magick-plus-plus --without-perl --without-x --disable-largefile --disable-openmp --without-bzlib --without-dps --without-freetype --without-jbig --without-openjp2 --without-lcms --without-wmf --without-xml --without-fftw --without-flif --without-fpx --without-djvu --without-fontconfig --without-raqm --without-gslib --without-gvc --without-heic --without-lqr --without-openexr --without-pango --without-raw --without-rsvg --without-webp --without-xml 
# Those works fine
#		--without-openjp2 \
#		--without-fontconfig \
#		--without-jxl \
#		--without-lzma \

# This two have issues
#		--without-raw \
#		--without-heic \

build_ImageMagick() {
	# configure unrecognized options: --disable-asm, --disable-thread, --disable-multithreading
	emconfigure ./configure \
		--disable-shared \
		--disable-openmp \
		--disable-assert \
		--disable-docs \
		--without-threads \
		--without-perl \
		--prefix=$BUILD_DIR

	# emmake make -j$MAKE_JOBS
	# emmake make install
	emmake make install-libLTLIBRARIES -j$MAKE_JOBS
	emmake make install-pkgconfigDATA
	emmake make install-MagickCoreincarchHEADER
	emmake make install-MagickCoreincHEADERS
	emmake make install-magickppincHEADERS
	emmake make install-magickpptopincHEADERS
	emmake make install-MagickWandincHEADERS
}

# /bin/bash ./libtool --silent --tag=CC --mode=link emcc -I$OUT_INCLUDE_DIR -I. -L$OUT_LIB_DIR utilities/magick.c -lMagickCore-7.Q16HDRI -lMagickWand-7.Q16HDRI -ljbig -ltiff -lpng16 -ldjvulibre -lfftw3 -lfpx -lfontconfig -lfreetype -lwebp -lopenjp2 -lraw_r -ljpeg -llcms2 -lxml2 -lgvc -lxdot -lpathplan -lcgraph -lcdt -lz -o magick.html
#	-ljbig -ltiff -lpng16 -ldjvulibre -lfftw3 -lfpx -lfontconfig -lfreetype -lwebp -lopenjp2 -lraw_r -ljpeg -llcms2 -lxml2 -lgvc -lxdot -lpathplan -lcgraph -lcdt -lz \
#    -Wall -Wextra -Wpedantic -Wno-unused-parameter -Wcast-align -Wformat-security -Wframe-larger-than=65536 -Wmissing-format-attribute -Wnon-virtual-dtor -Woverloaded-virtual -Wmissing-declarations -Wundef -Wzero-as-null-pointer-constant -Wshadow -Wweak-vtables -fno-exceptions -fno-check-new -fno-common -D_DEFAULT_SOURCE \

# Supress --shared-memory error, but not safe to do that, reference https://github.com/emscripten-core/emscripten/issues/8503
#	-Wl,--shared-memory,--no-check-features \

link_js_file() {
  LAST_PWD=$(pwd)
  ## Set EMCC_DEBUG=2 to printout full compile debug info
  export EMCC_DEBUG=2
  emcc \
	-I$OUT_INCLUDE_DIR -I. \
	-L$OUT_LIB_DIR \
    -Wall -Wextra -Wpedantic -Wno-unused-parameter -Wcast-align -Wformat-security -Wframe-larger-than=65536 -Wmissing-format-attribute -Wnon-virtual-dtor -Woverloaded-virtual -Wmissing-declarations -Wundef -Wzero-as-null-pointer-constant -Wshadow -Wweak-vtables -fno-check-new -fno-common -D_DEFAULT_SOURCE \
	utilities/magick.c \
	-lMagickCore-7.Q16HDRI -lMagickWand-7.Q16HDRI \
	-ljbig -ltiff -lpng16 -ldjvulibre -lfftw3 -lfpx -lfontconfig -lfreetype -lwebp -lopenjp2 -lraw_r -ljpeg -llcms2 -lxml2 -lgvc -lxdot -lpathplan -lcgraph -lcdt -lz -ljxl -llzma -lheif \
	-O3 \
	--closure 1 \
	-pthread \
	--pre-js prepend.js \
	-o magick.js \
	-s ERROR_ON_UNDEFINED_SYMBOLS=0 \
	-s LLD_REPORT_UNDEFINED=1 \
	-s EXPORT_NAME="'MagickModule'" \
	-s MODULARIZE=1 \
	-s SINGLE_FILE=1 \
	-s ALLOW_MEMORY_GROWTH=1 \
	-s RESERVED_FUNCTION_POINTERS=1 \
	-s EXPORTED_FUNCTIONS="['_main']" \
	-s EXTRA_EXPORTED_RUNTIME_METHODS="[cwrap, FS, getValue, setValue]" \

  cd $LAST_PWD
}

#install_tools
#build_ImageMagick
link_js_file

