# Cross Platform Makefile
# Tested on Windows 10 (msys2 mingw64)

APP = imageeditor.exe

DEPS = thirdparty/cimgui/libcimgui.o
DEPS += thirdparty/sokol/sokol_glue.h
DEPS += thirdparty/sokol/util/sokol_imgui.h
DEPS += thirdparty/LibRaw/lib/libraw.a

# UNAME_S := $(shell uname -s)


VFLAGS += -d vsl_vcl_dlopencl
ifeq ($(OS),Windows_NT)
	CC = gcc
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
		CC = gcc
    endif
    ifeq ($(UNAME_S),Darwin)
		CC = clang
        VFLAGS += -cflags '-Wno-enum-conversion -Wno-pointer-sign -Wmissing-prototypes -framework OpenCL -lstdc++'
    endif
endif

all: deps ${APP}

${APP}: $(DEPS)
	v -cc ${CC} -showcc ${VFLAGS} .

dev: ${APP}
	v -cc ${CC} -showcc ${VFLAGS} watch run .

deps: cimgui sokol libraw

.PHONY: cimgui
cimgui:
# cd thirdparty && git clone --recursive https://github.com/cimgui/cimgui.git
	cd thirdparty && git clone --branch 1.91.1 --recursive https://github.com/cimgui/cimgui.git
	cd thirdparty/cimgui && $(MAKE) static
# FOR SHARED DLL INSTEAD OF STATIC, UNCOMMENT BELOW
# copy dll to ./src
# cp ./thirdparty/cimgui/libcimgui.dll ./src
# use -std=c++11

.PHONY: sokol
sokol:
# cd thirdparty && git clone https://github.com/floooh/sokol
  cd thirdparty && git clone --branch pre-bindings-cleanup https://github.com/floooh/sokol/

.PHONY: libraw
libraw:
# cd thirdparty && git clone https://github.com/LibRaw/LibRaw
	cd thirdparty && git clone --branch 0.21.2 https://github.com/LibRaw/LibRaw
	cd thirdparty/LibRaw && $(MAKE) -f Makefile.dist library
# for win users, you may need to use msys2 mingw64 for this ^
# or change it to Makefile.mingw
# or add LDADD+=-lws2_32, see https://github.com/LibRaw/LibRaw/issues/267
# If you don't have zlib installed, it is optional
# You may need to comment out the lines in thirdparty/LibRaw/Makefile.dist
# ZLIB support (FP dng)
#CFLAGS+=-DUSE_ZLIB
#LDADD+=-lz

.PHONY: clean
clean:
	rm -f ${APP}

.PHONY: cleandeps
cleandeps:
	rm -f $(OBJS)
# rm -rf thirdparty/cimgui
# rm -rf thirdparty/sokol
# rm -rf thirdparty/LibRaw
