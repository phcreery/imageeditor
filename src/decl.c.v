module main

import libs.libraw as _
import libs.cimgui as _

// both cimgui/imgui and LibRaw need libstdc++
// to ensure it gets linked last, we put it here, after the imports above
#flag -lstdc++

$if darwin ? {
	#flag -Wno-enum-conversion 
	#flag -Wno-pointer-sign 
	#flag -Wmissing-prototypes 
	#flag -framework OpenCL 
	#flag -lstdc++ 
	#flag -v
}