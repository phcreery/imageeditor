module simgui

import sokol.gfx
import sokol.memory

@[typedef]
pub struct C.simgui_allocator_t {
pub mut:
	alloc     memory.FnAllocatorAlloc
	free      memory.FnAllocatorFree
	user_data voidptr
	// void* (*alloc)(size_t size, void* user_data)
	// void (*free)(void* ptr, void* user_data)
	// user_data
}

pub type SimguiAllocator = C.simgui_allocator_t

@[typedef]
pub struct C.simgui_desc_t {
pub mut:
	max_vertices                      int
	color_format                      gfx.PixelFormat // C.sg_pixel_format
	depth_format                      gfx.PixelFormat // C.sg_pixel_format
	sample_count                      int
	ini_filename                      &char // string // const char*
	no_default_font                   bool
	disable_paste_override            bool                 // if true, don't send Ctrl-V on EVENTTYPE_CLIPBOARD_PASTED
	disable_set_mouse_cursor          bool                 // if true, don't control the mouse cursor type via sapp_set_mouse_cursor()
	disable_windows_resize_from_edges bool                 // if true, only resize edges from the bottom right corner
	write_alpha_channel               bool                 // if true, alpha values get written into the framebuffer
	allocator                         C.simgui_allocator_t // optional memory allocation overrides (default: malloc/free)
}

pub type SimguiDesc = C.simgui_desc_t

@[typedef]
pub struct C.simgui_frame_desc_t {
pub mut:
	width      int
	height     int
	delta_time f64 // double
	dpi_scale  f64
}

pub type SimguiFrameDesc = C.simgui_frame_desc_t
