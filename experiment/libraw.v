module main

import libs.libraw
import libs.cimgui

fn main() {
	cimgui_version := cimgui.get_version()
	dump(cimgui_version)

	lr_version := libraw.libraw_version()
	dump(lr_version)
}
