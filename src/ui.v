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

	cimgui_version string = unsafe { cstring_to_vstring(&char(cimgui.ig_get_version())) }
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
	pos     cimgui.ImVec2 = cimgui.ImVec2{sapp.width() - 400 - 10, 10}
	size    cimgui.ImVec2 = cimgui.ImVec2{400, 600}
}

struct UIWindows {
	about   UIWindowAbout      = UIWindowAbout{}
	basic   UIWindowBasicEdits = UIWindowBasicEdits{}
	catalog UIWindowCatalog    = UIWindowCatalog{}
}

fn UIWindows.new() UIWindows {
	return UIWindows{}
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

	for backend in state.center_image_pixpipe.backends {
		cimgui.ig_text('Backend: ${backend.name} ${backend.version}'.str)
	}

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

	load_pressed := cimgui.ig_button('Open'.str, cimgui.ImVec2{40, 20})
	if load_pressed {
		state.open_image_dev()
	}

	mut image_names := []string{}
	for mut image in state.catalog.images {
		image_names << '${image.path} (${image.status})'
	}
	selected := state.catalog_current_image_index
	mut image_names_ptrs := []&u8{len: image_names.len, init: 0}
	for i, item in image_names {
		image_names_ptrs[i] = item.str
	}
	if image_names.len == 0 {
		image_names_ptrs = []&u8{len: 1, init: 0}
	}

	changed ||= cimgui.ig_list_box_str_arr('Catalog'.str, &selected, &image_names_ptrs[0],
		image_names.len, 5)
	if changed {
		state.set_catalog_current_image_index(selected)
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
	// changed ||= cimgui.checkbox('Invert', &state.center_image_pixpipe.invert.enabled)
	// dump(changed)
	// changed ||= cimgui.checkbox('Grayscale', &state.center_image_pixpipe.grayscale)

	for mut edit in state.center_image_pixpipe.edits {
		changed ||= edit.draw()
	}

	state.center_image_pixpipe.dirty ||= changed
	cimgui.ig_end()
}

fn draw_windows(mut state AppState) {
	// v -cg ...
	$if debug {
		show_demo_window := true
		cimgui.ig_show_metrics_window(&show_demo_window)
	}

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
					state.center_image_rendered.update(state.center_image_original)
				}
				else {
					// println('idk')
				}
			}
		}
		.key_up {
			match ev.key_code {
				.backslash {
					state.center_image_rendered.update(state.center_image_processed)
				}
				.space {
					state.center_image_rendered.reset_params()
				}
				else {
					// println('idk')
				}
			}
		}
		.mouse_move {
			if ev.modifiers == int(sapp.Modifier.lmb) {
				state.center_image_rendered.move(ev.mouse_dx, ev.mouse_dy)
			}
		}
		.mouse_scroll {
			state.center_image_rendered.scale(ev.scroll_y * 0.05)
		}
		else {
			// println('idk')
		}
	}
}
