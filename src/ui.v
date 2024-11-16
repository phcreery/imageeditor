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

	cimgui_version string = unsafe { cstring_to_vstring(char(cimgui.ig_get_version())) }
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
	cimgui.ig_set_next_window_pos(state.windows.about.pos, .im_gui_cond_once, cimgui.ImVec2{0, 0})
	cimgui.ig_set_next_window_size(state.windows.about.size, .im_gui_cond_once)

	// begin
	cimgui.ig_begin('About'.str, &state.windows.about.is_open, .im_gui_window_flags_none)
	// content
	cimgui.ig_text("PIE: Peyton's Image Editor v${state.version}".str)
	cimgui.ig_text('v hash: ${@VHASH}'.str)
	cimgui.ig_text('build date: ${@BUILD_DATE} ${@BUILD_TIME}'.str)
	cimgui.ig_text('cimgui version: ${state.windows.about.cimgui_version}'.str)
	cimgui.ig_text('LibRaw version: ${state.windows.about.libraw_version}'.str)
	cimgui.ig_text('Backend: ${state.pixpipe.backend.name} (${state.pixpipe.backend.version})'.str)

	cimgui.ig_text('FPS: ${i32(state.fg.fps)} (${state.fg.fps_max()}|${state.fg.fps_min()})'.str)
	cimgui.ig_plot_lines_float_ptr('FPS'.str, state.fg.fps_history.data, 100, 0, c'',
		0, 120, cimgui.ImVec2{0, 80}, sizeof(f32))

	cimgui.ig_text('Duty cycle: ${state.fg.duty_cycle}'.str)
	cimgui.ig_plot_lines_float_ptr('Duty cycle'.str, state.fg.duty_history.data, 100,
		0, c'', 0, 1, cimgui.ImVec2{0, 80}, sizeof(f32))

	// end
	cimgui.ig_end()
}

fn draw_catalog_window(mut state AppState) {
	if !state.windows.catalog.is_open {
		return
	}

	mut changed := false

	// initialize
	cimgui.ig_set_next_window_pos(state.windows.catalog.pos, .im_gui_cond_once, cimgui.ImVec2{0, 0})
	cimgui.ig_set_next_window_size(state.windows.catalog.size, .im_gui_cond_once)

	// begin
	cimgui.ig_begin(c'Catalog', &state.windows.catalog.is_open, .im_gui_window_flags_none)
	// content
	mut images := []string{}
	for mut image in state.catalog.images {
		images << image.path
	}
	// selected_old := state.catalog_current_image_index
	selected := state.catalog_current_image_index
	mut items_ptrs := []&u8{len: images.len, init: 0}
	for i, item in images {
		items_ptrs[i] = item.str
	}
	if images.len == 0 {
		items_ptrs = []&u8{len: 1, init: 0}
	}

	changed ||= cimgui.ig_list_box_str_arr('Catalog'.str, &selected, &items_ptrs[0], images.len,
		5)
	if changed {
		println('changed ${selected}')
		state.original_image = state.catalog.images[selected].image or {
			panic('failed to load image')
		}

		// TODO: move this to a function
		state.processed_image = state.original_image.clone() // this takes time
		state.rendered_image.create(state.original_image)
		state.rendered_image.update(state.original_image)
		state.rendered_image.reset_params()
	}
	// end
	cimgui.ig_end()
}

fn draw_edit_window(mut state AppState) {
	mut changed := false
	cimgui.ig_set_next_window_pos(state.windows.basic.pos, .im_gui_cond_once, cimgui.ImVec2{0, 0})
	cimgui.ig_set_next_window_size(state.windows.basic.size, .im_gui_cond_once)
	cimgui.ig_begin('Basic Edits'.str, &state.windows.basic.is_open, .im_gui_window_flags_none)
	// cimgui.color_edit3('Background', &state.pass_action.colors[0].clear_value.r, 0)
	// changed ||= cimgui.checkbox('Invert', &state.pixpipe.invert.enabled)
	// dump(changed)
	// changed ||= cimgui.checkbox('Grayscale', &state.pixpipe.grayscale)

	for mut edit in state.pixpipe.edits {
		changed ||= edit.draw()
	}

	state.pixpipe.dirty ||= changed
	cimgui.ig_end()
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
					state.rendered_image.update(state.original_image)
				}
				else {
					// println('idk')
				}
			}
		}
		.key_up {
			match ev.key_code {
				.backslash {
					state.rendered_image.update(state.processed_image)
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
