################################################################################
# Makefile to build SDL and its dependencies from source.
#
# This Makefile is designed to be called from the main project's Makefile.
# It inherits the PREFIX and build flags from the parent environment.
################################################################################

# Source code locations within the jivemax-sdl repository
SRC_FREETYPE  = freetype-2.9.1
SRC_LIBPNG    = libpng-1.2.59
SRC_JPEG      = jpeg-9d
SRC_SDL       = SDL-1.2.15
SRC_SDL_IMAGE = SDL_image-1.2.5
SRC_SDL_TTF   = SDL_ttf-2.0.15
SRC_SDL_GFX   = SDL_gfx-2.0.15

# Main target: build all SDL-related libraries
.PHONY: all
all: freetype libpng libjpeg sdl sdl-image sdl-ttf sdl-gfx

# Ensure the prefix directories exist before starting
$(shell mkdir -p $(PREFIX)/include $(PREFIX)/lib)

###
# Build targets for each dependency
###

$(SRC_FREETYPE)/config.mk:
	cd $(SRC_FREETYPE); chmod +x autogen.sh; ./autogen.sh; chmod +x configure; ./configure --prefix=$(PREFIX) $(ENABLE_SHARED_LIBS)
freetype: $(SRC_FREETYPE)/config.mk
	$(MAKE) -C $(SRC_FREETYPE)
	$(MAKE) -C $(SRC_FREETYPE) install

$(SRC_LIBPNG)/Makefile:
	cd $(SRC_LIBPNG); \
	chmod +x configure; \
	CPPFLAGS="-I$(PREFIX)/include" LDFLAGS="-L$(PREFIX)/lib" \
	./configure --prefix=$(PREFIX) --enable-static=no
libpng: $(SRC_LIBPNG)/Makefile
	$(MAKE) -C $(SRC_LIBPNG)
	$(MAKE) -C $(SRC_LIBPNG) install

$(SRC_JPEG)/Makefile:
	cd $(SRC_JPEG); chmod +x configure; ./configure --prefix=$(PREFIX) --enable-static=no
libjpeg: $(SRC_JPEG)/Makefile
	$(MAKE) -C $(SRC_JPEG)
	$(MAKE) -C $(SRC_JPEG) install

$(SRC_SDL)/Makefile:
	cd $(SRC_SDL); chmod +x autogen.sh; ./autogen.sh; \
	chmod +x configure; ./configure --prefix=$(PREFIX) $(ENABLE_SHARED_LIBS) \
		--enable-audio=no \
		--enable-video \
		--enable-events \
		--enable-joystick=no \
		--enable-cdrom=no \
		--enable-threads \
		--enable-timers \
		--enable-file \
		--enable-loadso \
		--enable-esd=no \
		--enable-arts=no \
		--enable-esd-shared=no \
		--enable-clock_gettime \
		--enable-video-x11=no \
		--enable-video-opengl=no \
		--enable-video-dummy=no \
		--enable-video-directfb=no \
		--enable-pulseaudio=no \
		--enable-input-tslib=yes

sdl: $(SRC_SDL)/Makefile
	$(MAKE) -C $(SRC_SDL)
	$(MAKE) -C $(SRC_SDL) install

$(SRC_SDL_IMAGE)/Makefile: sdl libjpeg libpng
	cd $(SRC_SDL_IMAGE); \
	chmod +x autogen.sh; ./autogen.sh; \
	chmod +x configure; \
	CPPFLAGS="-I$(PREFIX)/include" LDFLAGS="-L$(PREFIX)/lib" \
	SDL_CONFIG=$(PREFIX)/bin/sdl-config ./configure \
		--prefix=$(PREFIX) $(ENABLE_SHARED_LIBS) --disable-tif
sdl-image: $(SRC_SDL_IMAGE)/Makefile
	$(MAKE) -C $(SRC_SDL_IMAGE)
	$(MAKE) -C $(SRC_SDL_IMAGE) install

$(SRC_SDL_TTF)/Makefile: sdl freetype
	cd $(SRC_SDL_TTF); chmod +x autogen.sh; ./autogen.sh; chmod +x configure; SDL_CONFIG=$(PREFIX)/bin/sdl-config ./configure \
		--prefix=$(PREFIX) $(ENABLE_SHARED_LIBS) --with-freetype-prefix=$(PREFIX) --without-opengl
sdl-ttf: $(SRC_SDL_TTF)/Makefile
	$(MAKE) -C $(SRC_SDL_TTF)
	$(MAKE) -C $(SRC_SDL_TTF) install

$(SRC_SDL_GFX)/Makefile: sdl
	cd $(SRC_SDL_GFX); aclocal; automake --add-missing --copy --foreign; autoconf; ./configure --prefix=$(PREFIX) $(ENABLE_SHARED_LIBS) --disable-mmx
sdl-gfx: $(SRC_SDL_GFX)/Makefile
	$(MAKE) -C $(SRC_SDL_GFX)
	$(MAKE) -C $(SRC_SDL_GFX) install

###
# Clean targets
###
.PHONY: clean

clean:
	@echo "Cleaning SDL dependency source directories..."
	-$(MAKE) -C $(SRC_FREETYPE) distclean
	-$(MAKE) -C $(SRC_LIBPNG) distclean
	-$(MAKE) -C $(SRC_JPEG) distclean
	-$(MAKE) -C $(SRC_SDL) distclean
	-$(MAKE) -C $(SRC_SDL_IMAGE) distclean
	-$(MAKE) -C $(SRC_SDL_TTF) distclean
	-$(MAKE) -C $(SRC_SDL_GFX) distclean 