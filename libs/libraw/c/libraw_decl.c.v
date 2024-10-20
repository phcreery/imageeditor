module c

// ----- libraw.h -----
#flag -I @VMODROOT/thirdparty/LibRaw/libraw
#include "libraw.h"
// #include "libraw_alloc.h"
// #include "libraw_const.h"
// #include "libraw_datastream.h"
// #include "libraw_internal.h"
// #include "libraw_types.h"
// #include "libraw_version.h"

// ----- libraw.a -----
// #flag @VMODROOT/thirdparty/LibRaw/lib/libraw.a
#flag -L@VMODROOT/thirdparty/LibRaw/lib/ -lraw

// these have to be linked after libraw
// https://stackoverflow.com/questions/71717340/liblivemedia-throwing-undefined-reference-errors-when-linking-imp-xxxxxx
// https://stackoverflow.com/questions/2033608/mingw-linker-error-winsock
// https://github.com/LibRaw/LibRaw/issues/267
#flag -lwsock32
#flag -lws2_32
// since the libaray is c++, we need to inglude the c++ libs during linking
// https://stackoverflow.com/questions/7397302/why-cant-i-link-a-mixed-c-c-static-library-that-has-a-c-interface-using-gcc
#flag -lstdc++
#flag -lm
