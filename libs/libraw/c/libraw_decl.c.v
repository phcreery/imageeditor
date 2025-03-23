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


// All of these have to be linked after libraw
// https://stackoverflow.com/questions/71717340/liblivemedia-throwing-undefined-reference-errors-when-linking-imp-xxxxxx
// https://stackoverflow.com/questions/2033608/mingw-linker-error-winsock
// https://github.com/LibRaw/LibRaw/issues/267
#flag windows -lwsock32
#flag windows -lws2_32
// since the library is c++, we need to include the c++ libs during linking
// https://stackoverflow.com/questions/7397302/why-cant-i-link-a-mixed-c-c-static-library-that-has-a-c-interface-using-gcc
// #flag -lstdc++
// #flag -std=c++11
#flag -lm
