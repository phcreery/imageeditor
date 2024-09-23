module cimgui

import libs.cimgui.c as _

@[inline]
pub fn begin(name string, p_open &bool, flags ImGuiWindowFlags) bool {
	return C.igBegin(name.str, p_open, flags)
}

@[inline]
pub fn end() {
	C.igEnd()
}

@[inline]
pub fn create_context(shared_font_atlas &C.ImFontAtlas) &C.ImGuiContext {
	return C.igCreateContext(shared_font_atlas)
}

@[inline]
pub fn destroy_context(ctx &C.ImGuiContext) {
	C.igDestroyContext(ctx)
}

@[inline]
pub fn get_current_context() &C.ImGuiContext {
	return C.igGetCurrentContext()
}

@[inline]
pub fn set_current_context(ctx &C.ImGuiContext) {
	C.igSetCurrentContext(ctx)
}

@[inline]
pub fn set_next_window_pos(pos ImVec2, cond ImGuiCond, pivot ImVec2) {
	C.igSetNextWindowPos(pos, cond, pivot)
}

@[inline]
pub fn set_next_window_size(size ImVec2, cond ImGuiCond) {
	C.igSetNextWindowSize(size, cond)
}

@[inline]
pub fn color_edit3(label string, col &f32, flags int) bool {
	return C.igColorEdit3(label.str, col, flags)
}

@[inline]
pub fn get_version() string {
	return unsafe { cstring_to_vstring(C.igGetVersion()) }
}


pub fn text(text string) {
	C.igText(text.str)
}