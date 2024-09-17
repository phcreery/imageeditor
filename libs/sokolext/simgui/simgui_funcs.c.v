module simgui

import sokol.sapp

fn C.simgui_setup(desc &C.simgui_desc_t)
fn C.simgui_new_frame(desc &C.simgui_frame_desc_t)
fn C.simgui_render()

// #if !defined(SOKOL_IMGUI_NO_SOKOL_APP)

fn C.simgui_handle_event(ev &sapp.Event) bool // sapp.C.sapp_event
fn C.simgui_map_keycode(keycode sapp.KeyCode) int // returns ImGuiKey_*

// #endif

fn C.simgui_shutdown()
