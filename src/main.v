module main

import sokol.sapp
import sokol.gfx
import sokol.sgl
import libs.sokolext as _
import libs.sokolext.simgui
import processing
import edit
import imageio

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
pub struct AppState {
mut:
	pass_action     gfx.PassAction
	original_image  imageio.Image
	processed_image imageio.Image
	rendered_image  GfxImage
	checkerboard    GfxCheckerboard
	windows         UIWindows
	// backend         processing.Backend
	pipeline edit.Pipeline
	fg       FrameGovernor
}

fn init(mut state AppState) {
	// logger := gfx.Logger{
	// 	// log_cb: my_log
	// 	log_cb: memory.slog
	// 	// user_data: ...
	// }

	// setup sokol-gfx with glue
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

	init_image(mut state)
	init_bg(mut state)
	state.fg = FrameGovernor{
		target_fps: 30.0
	}

	// DEV
	// image_path := 'Lenna.png'
	// image_path := 'sample/LIT_9419.JPG_edit.bmp'
	// mut image := load_image(image_path)

	image_path := 'sample/DSC_6765.NEF'
	state.original_image = imageio.load_image_raw(image_path)
	state.processed_image = state.original_image.clone()

	// TESTING
	// processing.invert(mut image)
	// END TESTING

	create_image(mut state, state.original_image)
	// state.backend = processing.Backend.new()
	state.pipeline = edit.init_pipeline()
}

fn create_image(mut state AppState, image imageio.Image) {
	state.rendered_image.reset_params()
	state.rendered_image.width = f32(image.width)
	state.rendered_image.height = f32(image.height)

	// see v/sokol examples for create_texture()
	mut tmp_imgdata := gfx.ImageData{}
	tmp_imgdata.subimage[0][0] = gfx.Range{
		ptr:  image.data.data
		size: usize(image.width * image.height * 4)
	}

	image_desc := gfx.ImageDesc{
		width:        image.width
		height:       image.height
		pixel_format: gfx.PixelFormat.rgba8 // rgb8 deprecated
		data:         tmp_imgdata
	}

	state.rendered_image.image = gfx.make_image(&image_desc)
	println('rendered_image created')
	dump(state.rendered_image.image)
}

fn frame(mut state AppState) {
	if state.pipeline.dirty {
		// do processing
		println('processing')
		state.pipeline.process(state.original_image, mut state.processed_image)
		create_image(mut state, state.processed_image)
		state.pipeline.dirty = false
	}

	frame_duration := sapp.frame_duration()
	state.fg.sleep_remaining(frame_duration)
	desc := simgui.SimguiFrameDesc{
		width:      sapp.width()
		height:     sapp.height()
		delta_time: frame_duration
		dpi_scale:  sapp.dpi_scale()
	}
	simgui.new_frame(desc)

	// UI START
	draw_windows(mut state)
	// UI END

	// SGL BEGIN
	disp_w := f32(sapp.width())
	disp_h := f32(sapp.height())
	sgl.defaults()
	sgl.enable_texture()
	sgl.matrix_mode_projection()
	sgl.ortho(-disp_w * 0.5, disp_w * 0.5, disp_h * 0.5, -disp_h * 0.5, -1.0, 1.0)

	canvas_draw_checkerboard(state, disp_w, disp_h)
	canvas_draw_image(state)
	// SGL END

	// DRAW PASS
	pass := sapp.create_default_pass(state.pass_action)
	gfx.begin_pass(&pass)
	sgl.draw()
	simgui.render()
	gfx.end_pass()
	gfx.commit()
}

fn cleanup(mut state AppState) {
	// state.backend.shutdown()
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
