module c

// #flag -DSOKOL_D3D11

$if emscripten ? {
	// #flag -DSOKOL_GLES2
	#flag -DSOKOL_GLES3

	// Flags for Emscripten
	// Needed with WebGL 2 (GL ES 3.0)
	// #flag -sMAX_WEBGL_VERSION=2
	#flag -sUSE_WEBGL2=1

	// WASM+JS size optimizations used by floooh (sokol)
	// https://github.com/emscripten-core/emscripten/issues/19363
	// #flag -sNO_FILESYSTEM=1 -sASSERTIONS=0 -sMALLOC=emmalloc --closure=1
	// V needs a filesystem because at startup it does a "_const_os__wd_at_startup = os__getwd();" in _vinit()
	// #flag -sNO_FILESYSTEM=1
	#flag -s ASSERTIONS=1
	#flag -s "MALLOC='emmalloc'"
	#flag --closure=1

	#flag -s ERROR_ON_UNDEFINED_SYMBOLS=1
	// #flag -sWARN_ON_UNDEFINED_SYMBOLS=1
	#flag -s MODULARIZE=0
	#flag -o @VMODROOT\build\wasm\vchip8.html
	#flag --shell-file @VMODROOT\shell_minimal.html

	// keep function names
	#flag -g3
}

// #flag -I @VMODROOT/thirdparty/cimgui/imgui
// #include "imgui.h"

// ----- sokol_imgui.h/sokol_glue.h -----
#flag -I @VMODROOT/thirdparty/sokol
#flag -I @VMODROOT/thirdparty/sokol/util
