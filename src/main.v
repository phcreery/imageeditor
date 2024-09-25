module main

import sokol.sapp
import sokol.gfx
import sokol.sgl
import libs.sokolext as _
import libs.sokolext.simgui
import stbi
import os
import arrays
import libs.libraw


struct Color {
mut:
	r f32
	g f32
	b f32
}

struct Offset {
pub mut:
	x f32
	y f32
}

@[heap]
struct Checkerboard {
pub mut:
	image   gfx.Image
	sampler gfx.Sampler
}

@[heap]
struct GfxImage {
pub mut:
	image   gfx.Image
	sampler gfx.Sampler
	// pipeline gfx.Pipeline
	pipeline sgl.Pipeline
	width    f32
	height   f32
	scale    f32
	offset   Offset
	color    Color
}

@[heap]
pub struct AppState {
mut:
	pass_action gfx.PassAction
	image        GfxImage
	checkerboard Checkerboard
	windows UIWindows
}

fn init(mut state AppState) {
	// logger := gfx.Logger{
	// 	// log_cb: my_log
	// 	log_cb: memory.slog
	// 	// user_data: ...
	// }
	// desc := gfx.Desc{
	// 	context: glue.sgcontext()
	// 	// logger: logger
	// }

	// Setup sokol-gfx
	desc := sapp.create_desc()
	gfx.setup(&desc)

	// Setup sokol-gl
	sgl_desc := sgl.Desc{}
	sgl.setup(&sgl_desc)

	// Setup simgui
	simgui_desc := simgui.SimguiDesc{}
	simgui.setup(&simgui_desc) // TODO

	// initial clear color
	state.pass_action = gfx.PassAction{}
	state.pass_action.colors[0] = gfx.ColorAttachmentAction{
		load_action: .dontcare //.clear
		// clear_value: gfx.Color{0.0, 0.5, 1.0, 0.5}
	}

	// a sampler object for nearest mag filter and linear min filter
	sampler_desc := &gfx.SamplerDesc{
		mag_filter: gfx.Filter.nearest
		min_filter: gfx.Filter.linear
		wrap_u:     gfx.Wrap.clamp_to_edge
		wrap_v:     gfx.Wrap.clamp_to_edge
	}
	state.image.sampler = gfx.make_sampler(sampler_desc)
	dump(state.image.sampler)

	// create a pipeline object with alpha blending for rendering the loaded image
	mut pipeline_desc := gfx.PipelineDesc{}
	unsafe { vmemset(&pipeline_desc, 0, int(sizeof(pipeline_desc))) }
	pipeline_desc.colors[0] = gfx.ColorTargetState{
		// write_mask: gfx.ColorMask.rgb
		blend: gfx.BlendState{
			enabled:        true
			src_factor_rgb: gfx.BlendFactor.src_alpha
			dst_factor_rgb: gfx.BlendFactor.one_minus_src_alpha
		}
	}
	state.image.pipeline = sgl.make_pipeline(&pipeline_desc)
	// state.image.pipeline = gfx.make_pipeline(&pipeline_desc)
	dump(state.image.pipeline)

	// texture and sampler for rendering checkboard background
	mut pixels := [][]u32{len: 4, init: []u32{len: 4}}
	for y := 0; y < 4; y++ {
		for x := 0; x < 4; x++ {
			if (x ^ y) & 1 == 1 {
				pixels[y][x] = u32(0xFF666666)
			} else {
				pixels[y][x] = u32(0xFF333333)
			}
		}
	}

	// SG_RANGE(x) sg_range{ &x, sizeof(x) }
	mut tmp_sbc := gfx.ImageData{}
	tmp_sbc.subimage[0][0] = gfx.Range{
		ptr:  arrays.flatten[u32](pixels).data
		size: usize(arrays.flatten[u32](pixels).len * sizeof(pixels[0][0]))
	}
	mut image_desc := gfx.ImageDesc{
		width:        4
		height:       4
		label:        &u8(0)
		pixel_format: gfx.PixelFormat.rgba8 // rgb8 deprecated
		data:         tmp_sbc
	}

	state.checkerboard.image = gfx.make_image(&image_desc)
	dump(state.checkerboard.image)

	state.checkerboard.sampler = gfx.make_sampler(&gfx.SamplerDesc{
		min_filter: gfx.Filter.nearest
		mag_filter: gfx.Filter.nearest
		wrap_u:     gfx.Wrap.repeat
		wrap_v:     gfx.Wrap.repeat
	})
	dump(state.checkerboard.sampler)

	// create_image(mut state)
	create_image_raw(mut state)
}

fn reset_image_params(mut state AppState) {
	state.image.scale = 0.1
	state.image.offset.x = 0.0
	state.image.offset.y = 0.0
	state.image.color.r = 1.0
	state.image.color.g = 1.0
	state.image.color.b = 1.0
}

fn create_image(mut state AppState) {
	// image_path := 'Lenna.png'
	image_path := 'sample/LIT_9419.JPG_edit.bmp'
	// image_path := 'LIT_9419.JPG'
	params := stbi.LoadParams{
		desired_channels: 4
	}
	buffer := os.read_bytes(image_path) or { panic('failed to read image') }
	dump(buffer.data)
	stbi_image := stbi.load_from_memory(buffer.data, buffer.len, params) or {
		panic('failed to load image')
	}
	defer {
		stbi_image.free()
	}
	dump(stbi_image)

	// buf := unsafe {
	// 	arrays.carray_to_varray[u8](stbi_image.data, stbi_image.width * stbi_image.height * 4)
	// }

	reset_image_params(mut state)

	state.image.width = f32(stbi_image.width)
	state.image.height = f32(stbi_image.height)

	// see v/sokol examples for create_texture()
	mut tmp_sbc := gfx.ImageData{}
	tmp_sbc.subimage[0][0] = gfx.Range{
		ptr:  stbi_image.data
		size: usize(stbi_image.width * stbi_image.height * 4)
	}
	image_desc := gfx.ImageDesc{
		width:        stbi_image.width
		height:       stbi_image.height
		pixel_format: gfx.PixelFormat.rgba8 // rgb8 deprecated
		data: tmp_sbc
	}
	state.image.image = gfx.make_image(&image_desc)
	println('image created')
	dump(state.image.image)
}

fn create_image_raw(mut state AppState) {
	image_path := 'sample/DSC_6765.NEF'
	// image_path := 'sample/RAW_NIKON_D100.NEF'
	libraw_data := libraw.libraw_init(.none_)
	println('libraw initialized')

	// Open the file and read the metadata
	mut status := libraw.libraw_open_file(libraw_data, image_path)
	println('file opened ${status}')
	
	// The metadata are accessible through data fields
	// dump(libraw_data.image)

	// Let us unpack the image
	status = libraw.libraw_unpack(libraw_data)
	println('unpacked ${status}')

	// Convert from imgdata.rawdata to imgdata.image using raw2image
	// status = libraw.libraw_raw2image(libraw_data)
	// println('raw2image ${status}')
	// dump(libraw_data.image)
	// buffer_size := libraw_data.sizes.iwidth * libraw_data.sizes.iheight
	// r := arrays.carray_to_varray[i16](libraw_data.image[0], buffer_size)
	// g := arrays.carray_to_varray[i16](libraw_data.image[1], buffer_size)
	// b := arrays.carray_to_varray[i16](libraw_data.image[2], buffer_size)
	// g2 := arrays.carray_to_varray[i16](libraw_data.image[3], buffer_size)

	// Convert from imgdata.rawdata to imgdata.image using dcraw_process
	status = libraw.libraw_dcraw_process(libraw_data)
	println('dcraw_process ${status}')
	libraw_processed_image := libraw.libraw_dcraw_make_mem_image(libraw_data, &status)
	println('dcraw_make_mem_image ${status}')
	dump(libraw_processed_image)

	println('libraw_processed_image.data ${libraw_processed_image.data}')

	mut data := unsafe { arrays.carray_to_varray[u8](libraw_processed_image.data, libraw_processed_image.data_size) }

	// convert from rgb to rgba
	println('data first 4 bytes ${data[0]} ${data[1]} ${data[2]} ${data[3]}')
	mut data_rgba := []u8{len: int(libraw_processed_image.width * libraw_processed_image.height * 4)}
	for i := 0; i < libraw_processed_image.width * libraw_processed_image.height; i++ {
		data_rgba[i * 4 + 0] = data[i * 3 + 0]
		data_rgba[i * 4 + 1] = data[i * 3 + 1]
		data_rgba[i * 4 + 2] = data[i * 3 + 2]
		data_rgba[i * 4 + 3] = 0xFF
	}
	println('data_rgba first 4 bytes ${data_rgba[0]} ${data_rgba[1]} ${data_rgba[2]} ${data_rgba[3]}')


	// let's create a new image
	reset_image_params(mut state)
	state.image.width = f32(libraw_processed_image.width)
	state.image.height = f32(libraw_processed_image.height)


	mut tmp_sbc := gfx.ImageData{}
	tmp_sbc.subimage[0][0] = gfx.Range{
		ptr:  data_rgba.data
		size: usize(libraw_processed_image.width * libraw_processed_image.height * 4)
	}
	image_desc := gfx.ImageDesc{
		width:        int(libraw_processed_image.width)
		height:       int(libraw_processed_image.height)
		pixel_format: gfx.PixelFormat.rgba8 // rgb8 deprecated
		data: 	      tmp_sbc
	}
	state.image.image = gfx.make_image(&image_desc)
	println('image created')
	// dump(image)

}

fn frame(mut state AppState) {
	desc := simgui.SimguiFrameDesc{
		width:      sapp.width()
		height:     sapp.height()
		delta_time: sapp.frame_duration()
		dpi_scale:  sapp.dpi_scale()
	}
	simgui.new_frame(desc)


	//=== UI CODE STARTS HERE ===
	draw_about_window(mut state)
	draw_rgb_window(mut state)
	//=== UI CODE ENDS HERE ===

	// BEGIN SGL
	disp_w := f32(sapp.width())
	disp_h := f32(sapp.height())
	sgl.defaults()
	sgl.enable_texture()
	sgl.matrix_mode_projection()
	sgl.ortho(-disp_w * 0.5, disp_w * 0.5, disp_h * 0.5, -disp_h * 0.5, -1.0, 1.0)

	canvas_draw_checkerboard(state, disp_w, disp_h)
	canvas_draw_image(state)

	// END SGL

	pass := sapp.create_default_pass(state.pass_action)
	gfx.begin_pass(&pass)
	sgl.draw()
	simgui.render()
	gfx.end_pass()
	gfx.commit()
}

fn cleanup(mut state AppState) {
	simgui.shutdown()
	sgl.shutdown()
	gfx.shutdown()
}

fn main() {
	title := "Peyton's Image Editor"

	mut state := &AppState{}
	desc := sapp.Desc{
		user_data:           state
		init_userdata_cb:    init
		frame_userdata_cb:   frame
		cleanup_userdata_cb: cleanup
		event_userdata_cb:   event
		window_title:        title.str
		html5_canvas_name:   title.str
	}

	sapp.run(&desc)
}
