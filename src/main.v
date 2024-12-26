module main

import sokol.sapp
import sokol.gfx
import sokol.sgl
import libs.sokolext as _
import libs.sokolext.simgui
import edit
import imageio
import v.vmod
import benchmark
// import libs.stb.image.resize as stbir
// import stbi
// import arrays

@[heap]
pub struct AppState {
	version string
mut:
	catalog                     imageio.Catalog
	catalog_current_image_index int
	center_image_original       imageio.Image
	center_image_processed      &imageio.Image = &imageio.Image{}
	center_image_pixpipe        edit.PixelPipeline
	// center_image_scale          f64 = 1
	center_image_scale_factors    []f64 = [0.1, 0.2, 0.5, 1]
	center_image_scale_factor_idx int   = 3

	// ui
	pass_action           gfx.PassAction
	center_image_rendered GfxImage
	checkerboard          GfxTexture
	windows               UIWindows
	fg                    FrameGovernor
}

fn (mut state AppState) set_catalog_current_image_index(index int) {
	if state.catalog.images[index].status != imageio.LoadStatus.loaded {
		return
	}

	img := state.catalog.images[index].image or { panic('failed to load image') }
	state.catalog_current_image_index = index

	state.center_image_original = img
	state.prepare_image_processing()
	state.center_image_pixpipe.dirty = true
}

fn (mut state AppState) prepare_image_processing() {
	state.center_image_original = state.center_image_original.scaled(state.center_image_scale_factors[state.center_image_scale_factor_idx])
	state.center_image_processed = &imageio.Image{
		width:  state.center_image_original.width
		height: state.center_image_original.height
	}
	state.center_image_rendered.create(state.center_image_original)
	state.center_image_rendered.update(state.center_image_original)
	state.center_image_rendered.reset_params()
}

fn (mut state AppState) get_catalog_current_image_index() int {
	if state.catalog_current_image_index < 0 {
		state.catalog_current_image_index = 0
	}
	if state.catalog_current_image_index >= state.catalog.images.len {
		state.catalog_current_image_index = state.catalog.images.len - 1
	}
	return state.catalog_current_image_index
}

fn (mut state AppState) open_image_dev() {
	// DEV
	mut images := []string{}
	images << 'sample/DSC_6765.NEF'
	images << 'sample/photo_hat.jpg'
	// images << 'sample/Lenna.png'
	// images << 'sample/LIT_9419.JPG_edit.bmp'
	// state.center_image_original = imageio.load_image_raw(image_path)
	state.catalog.parallel_load_images_by_path(images)
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

	state.center_image_rendered = GfxImage.new()
	state.checkerboard = GfxTexture.new_checkerboard()

	state.fg = FrameGovernor{
		target_fps: 30.0
	}

	state.catalog = imageio.Catalog.new()

	state.center_image_pixpipe = edit.init_pixelpipeline()

	state.windows = UIWindows.new()

	// DEV
	state.open_image_dev()
	// state.set_catalog_current_image_index(selected)
}

fn frame(mut state AppState) {
	// Unhandled Exception 0x406D1388
	// happening on second frame on draw pass

	state.fg.begin_frame()
	if state.center_image_pixpipe.dirty {
		// do processing
		println('')
		// println('processing...')
		mut b := benchmark.start()
		state.center_image_pixpipe.process(state.center_image_original, mut state.center_image_processed)
		b.measure('main process')
		state.center_image_rendered.update(state.center_image_processed)
		b.measure('main update center image')
		println(b.total_message('main'))
		// println('done')
	}

	desc := simgui.SimguiFrameDesc{
		width:      sapp.width()
		height:     sapp.height()
		delta_time: sapp.frame_duration()
		dpi_scale:  sapp.dpi_scale()
	}
	simgui.new_frame(desc)

	// SGL BEGIN
	disp_w := f32(sapp.width())
	disp_h := f32(sapp.height())
	sgl.defaults()
	sgl.enable_texture()
	sgl.matrix_mode_projection()
	sgl.ortho(-disp_w * 0.5, disp_w * 0.5, disp_h * 0.5, -disp_h * 0.5, -1.0, 1.0)

	state.checkerboard.draw_checkerboard(disp_w, disp_h)
	state.center_image_rendered.draw()
	// SGL END

	// UI START
	draw_windows(mut state)
	// UI END

	// DRAW PASS
	pass := sapp.create_default_pass(state.pass_action)
	gfx.begin_pass(&pass)
	sgl.draw()
	simgui.render()
	gfx.end_pass()
	gfx.commit()

	state.fg.sleep_remaining()
}

fn cleanup(mut state AppState) {
	state.center_image_pixpipe.shutdown()
	simgui.shutdown()
	sgl.shutdown()
	gfx.shutdown()
}

fn main() {
	vmod_file := vmod.decode(@VMOD_FILE) or { panic('Error decoding v.mod') }
	print_console_header(vmod_file.version)
	title := "PIE: Peyton's Image Editor"

	mut state := &AppState{
		version: vmod_file.version
	}

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
