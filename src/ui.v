module main

import sokol.sapp
import libs.sokolext as _
import libs.cimgui
import libs.sokolext.simgui
import libs.libraw

struct CimguiState {
	is_open bool
	pos cimgui.ImVec2
	size cimgui.ImVec2
}

struct UIWindowAbout implements CimguiState {
	pub mut:
	is_open bool = true
	pos cimgui.ImVec2 = cimgui.ImVec2{10, 10}
	size cimgui.ImVec2 = cimgui.ImVec2{400, 100}
	
	cimgui_version string = cimgui.get_version()
	libraw_version string = libraw.libraw_version()
}


struct UIWindows {
	about UIWindowAbout
}

fn draw_about_window(mut state AppState) {
	if !state.windows.about.is_open { return }

	// initialize
	cimgui.set_next_window_pos(state.windows.about.pos, .im_gui_cond_once, cimgui.ImVec2{0, 0})
	cimgui.set_next_window_size(state.windows.about.size, .im_gui_cond_once)

	// begin
	cimgui.begin('About', &state.windows.about.is_open, .none_)
	// content
	cimgui.text('imageeditor')
	cimgui.text('cimgui version: ${state.windows.about.cimgui_version}')
	cimgui.text('LibRaw version: ${state.windows.about.libraw_version}')
	// end
	cimgui.end()

}

fn draw_rgb_window(mut state AppState) {
	
	window_pos := cimgui.ImVec2{10, 120}
	window_pivot := cimgui.ImVec2{0, 0}
	cimgui.set_next_window_pos(window_pos, .im_gui_cond_once, window_pivot)
	window_size := cimgui.ImVec2{400, 100}
	cimgui.set_next_window_size(window_size, .im_gui_cond_once)

	p_open := false
	cimgui.begin('Hello Dear ImGui from V!', &p_open, .none_)
	cimgui.color_edit3('Background', &state.pass_action.colors[0].clear_value.r, 0)
	cimgui.end()

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
		.key_up {
			match ev.key_code {
				.space { reset_image_params(mut state) }
				._1 { state.image.color.r = if state.image.color.r == 0.0 { 1 } else { 0 } }
				._2 { state.image.color.r = if state.image.color.r == 0.0 { 1 } else { 0 } }
				._3 { state.image.color.r = if state.image.color.r == 0.0 { 1 } else { 0 } }
				else { println('idk') }
			}
		}
		.mouse_move {
			if ev.modifiers == int(sapp.Modifier.lmb) {
				move(mut state, ev.mouse_dx, ev.mouse_dy)
			}
		}
		.mouse_scroll {
			scale(mut state, ev.scroll_y * 0.25)
		}
		else {
			println('idk')
		}
	}
}
