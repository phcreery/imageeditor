# Cross Platform Makefile
# Tested on Windows 10 (msys2 mingw64)

OBJS = thirdparty/cimgui/libcimgui.o
OBJS += thirdparty/sokol/sokol_glue.h
OBJS += thirdparty/sokol/util/sokol_imgui.h
OBJS += thirdparty/LibRaw/lib/libraw.a

UNAME_S := $(shell uname -s)

app: $(OBJS)
	v -cc cc -showcc .

cimgui:
	cd thirdparty && git clone --recursive https://github.com/cimgui/cimgui.git
	cd thirdparty/cimgui && $(MAKE) static
# FOR SHARED DLL INSTEAD OF STATIC, UNCOMMENT BELOW
# copy dll to ./src
# cp ./thirdparty/cimgui/libcimgui.dll ./src

sokol:
	cd thirdparty && git clone https://github.com/floooh/sokol

libraw:
	cd thirdparty && git clone https://github.com/LibRaw/LibRaw
	cd thirdparty/LibRaw && $(MAKE) -f Makefile.dist library
# for win users, you may need to use msys2 mingw64 for this ^
# or change it to Makefile.mingw
# or add LDADD+=-lws2_32, see https://github.com/LibRaw/LibRaw/issues/267
# If you don't have zlib installed, it is optional
# You may need to comment out the lines in thirdparty/LibRaw/Makefile.dist
# ZLIB support (FP dng)
#CFLAGS+=-DUSE_ZLIB
#LDADD+=-lz


clean:
	rm -f $(OBJS)
