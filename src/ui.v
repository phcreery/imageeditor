module main

import sokol.sapp
import libs.sokolext as _
import libs.cimgui
import libs.sokolext.simgui
import libs.libraw

interface CimguiState {
	is_open bool
	pos     cimgui.ImVec2
	size    cimgui.ImVec2
}

struct UIWindowAbout implements CimguiState {
pub mut:
	is_open bool          = true
	pos     cimgui.ImVec2 = cimgui.ImVec2{10, 10}
	size    cimgui.ImVec2 = cimgui.ImVec2{400, 350}

	cimgui_version string = cimgui.get_version()
	libraw_version string = libraw.libraw_version()
}

struct UIWindowCatalog implements CimguiState {
pub mut:
	is_open bool          = true
	pos     cimgui.ImVec2 = cimgui.ImVec2{10, 370}
	size    cimgui.ImVec2 = cimgui.ImVec2{400, 200}
}

struct UIWindowBasicEdits implements CimguiState {
pub mut:
	is_open bool          = true
	pos     cimgui.ImVec2 = cimgui.ImVec2{10, 580}
	size    cimgui.ImVec2 = cimgui.ImVec2{400, 100}
}

struct UIWindows {
	about   UIWindowAbout
	basic   UIWindowBasicEdits
	catalog UIWindowCatalog
}

fn draw_about_window(mut state AppState) {
	if !state.windows.about.is_open {
		return
	}

	// initialize
	cimgui.set_next_window_pos(state.windows.about.pos, .im_gui_cond_once, cimgui.ImVec2{0, 0})
	cimgui.set_next_window_size(state.windows.about.size, .im_gui_cond_once)

	// begin
	cimgui.begin('About', &state.windows.about.is_open, .none_)
	// content
	cimgui.text("PIE: Peyton's Image Editor")
	cimgui.text('v hash: ${@VHASH}')
	cimgui.text('build date: ${@BUILD_DATE} ${@BUILD_TIME}')
	cimgui.text('cimgui version: ${state.windows.about.cimgui_version}')
	cimgui.text('LibRaw version: ${state.windows.about.libraw_version}')
	cimgui.text('Backend: ${state.pipeline.backend.name} (${state.pipeline.backend.version})')

	cimgui.text('FPS: ${i32(state.fg.fps)} (${state.fg.fps_max()}|${state.fg.fps_min()})')
	cimgui.plot_lines_float_ptr('FPS', state.fg.fps_history.data, 100, 0, '', 0, 120,
		cimgui.ImVec2{0, 80}, sizeof(f32))

	cimgui.text('Duty cycle: ${state.fg.duty_cycle}')
	cimgui.plot_lines_float_ptr('Duty cycle', state.fg.duty_history.data, 100, 0, '',
		0, 1, cimgui.ImVec2{0, 80}, sizeof(f32))

	// end
	cimgui.end()
}

fn draw_catalog_window(mut state AppState) {
	if !state.windows.catalog.is_open {
		return
	}

	// initialize
	cimgui.set_next_window_pos(state.windows.catalog.pos, .im_gui_cond_once, cimgui.ImVec2{0, 0})
	cimgui.set_next_window_size(state.windows.catalog.size, .im_gui_cond_once)

	// begin
	cimgui.begin('Catalog', &state.windows.catalog.is_open, .none_)
	// content
	cimgui.text('Catalog')
	// cimgui.begin_list_box('Catalog', cimgui.ImVec2{0, 200})
	mut images := []string{}
	for mut image in state.catalog.images {
		images << image.path
	}
	// images << 'Another Image'
	// images << 'Another Image2'
	selected := 0
	label := 'Catalog'
	cimgui.list_box_str_arr(&label, &selected, images, 5)
	// end
	cimgui.end()
}

fn draw_edit_window(mut state AppState) {
	mut changed := false
	cimgui.set_next_window_pos(state.windows.basic.pos, .im_gui_cond_once, cimgui.ImVec2{0, 0})
	cimgui.set_next_window_size(state.windows.basic.size, .im_gui_cond_once)
	cimgui.begin('Basic Edits', &state.windows.basic.is_open, .none_)
	// cimgui.color_edit3('Background', &state.pass_action.colors[0].clear_value.r, 0)
	// changed ||= cimgui.checkbox('Invert', &state.pipeline.invert.enabled)
	// dump(changed)
	// changed ||= cimgui.checkbox('Grayscale', &state.pipeline.grayscale)

	for mut edit in state.pipeline.edits {
		changed ||= edit.draw()
	}

	state.pipeline.dirty ||= changed
	cimgui.end()
}

fn draw_windows(mut state AppState) {
	// show_demo_window := true
	// cimgui.show_metrics_window(&show_demo_window)

	draw_about_window(mut state)
	draw_edit_window(mut state)
	draw_catalog_window(mut state)
}

fn event(ev &sapp.Event, mut state AppState) {
	simgui_captured := simgui.handle_event(ev)
	if simgui_captured {
		return
	}
	match ev.@type {
		.files_dropped {
			println('files dropped')
		}
		.key_down {
			match ev.key_code {
				.backslash {
					render_image(mut state, state.original_image)
				}
				else {
					// println('idk')
				}
			}
		}
		.key_up {
			match ev.key_code {
				.backslash {
					render_image(mut state, state.processed_image)
				}
				.space {
					state.rendered_image.reset_params()
				}
				else {
					// println('idk')
				}
			}
		}
		.mouse_move {
			if ev.modifiers == int(sapp.Modifier.lmb) {
				state.rendered_image.move(ev.mouse_dx, ev.mouse_dy)
			}
		}
		.mouse_scroll {
			state.rendered_image.scale(ev.scroll_y * 0.05)
		}
		else {
			// println('idk')
		}
	}
}
