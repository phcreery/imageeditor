module cimgui

pub enum ImGuiCond {
	im_gui_cond_none           = 0
	// No condition (always set the variable), same as _Always
	im_gui_cond_always         = 1 << 0
	// No condition (always set the variable), same as _None
	im_gui_cond_once           = 1 << 1
	// Set the variable once per runtime session (only the first call will succeed)
	im_gui_cond_first_use_ever = 1 << 2
	// Set the variable if the object/window has no persistently saved data (no entry in .ini file)
	im_gui_cond_appearing      = 1 << 3
	// Set the variable if the object/window is appearing after being hidden/inactive (or the first time)
}

// typedef enum {
//     ImGuiWindowFlags_None = 0,
//     ImGuiWindowFlags_NoTitleBar = 1 << 0,
//     ImGuiWindowFlags_NoResize = 1 << 1,
//     ImGuiWindowFlags_NoMove = 1 << 2,
//     ImGuiWindowFlags_NoScrollbar = 1 << 3,
//     ImGuiWindowFlags_NoScrollWithMouse = 1 << 4,
//     ImGuiWindowFlags_NoCollapse = 1 << 5,
//     ImGuiWindowFlags_AlwaysAutoResize = 1 << 6,
//     ImGuiWindowFlags_NoBackground = 1 << 7,
//     ImGuiWindowFlags_NoSavedSettings = 1 << 8,
//     ImGuiWindowFlags_NoMouseInputs = 1 << 9,
//     ImGuiWindowFlags_MenuBar = 1 << 10,
//     ImGuiWindowFlags_HorizontalScrollbar = 1 << 11,
//     ImGuiWindowFlags_NoFocusOnAppearing = 1 << 12,
//     ImGuiWindowFlags_NoBringToFrontOnFocus = 1 << 13,
//     ImGuiWindowFlags_AlwaysVerticalScrollbar= 1 << 14,
//     ImGuiWindowFlags_AlwaysHorizontalScrollbar=1<< 15,
//     ImGuiWindowFlags_NoNavInputs = 1 << 16,
//     ImGuiWindowFlags_NoNavFocus = 1 << 17,
//     ImGuiWindowFlags_UnsavedDocument = 1 << 18,
//     ImGuiWindowFlags_NoDocking = 1 << 19,
//     ImGuiWindowFlags_NoNav = ImGuiWindowFlags_NoNavInputs | ImGuiWindowFlags_NoNavFocus,
//     ImGuiWindowFlags_NoDecoration = ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse,
//     ImGuiWindowFlags_NoInputs = ImGuiWindowFlags_NoMouseInputs | ImGuiWindowFlags_NoNavInputs | ImGuiWindowFlags_NoNavFocus,
//     ImGuiWindowFlags_ChildWindow = 1 << 24,
//     ImGuiWindowFlags_Tooltip = 1 << 25,
//     ImGuiWindowFlags_Popup = 1 << 26,
//     ImGuiWindowFlags_Modal = 1 << 27,
//     ImGuiWindowFlags_ChildMenu = 1 << 28,
//     ImGuiWindowFlags_DockNodeHost = 1 << 29,
// }ImGuiWindowFlags_;
pub enum ImGuiWindowFlags {
	none_                       = C.ImGuiWindowFlags_None
	no_title_bar                = C.ImGuiWindowFlags_NoTitleBar
	no_resize                   = C.ImGuiWindowFlags_NoResize
	no_move                     = C.ImGuiWindowFlags_NoMove
	no_scrollbar                = C.ImGuiWindowFlags_NoScrollbar
	no_scroll_with_mouse        = C.ImGuiWindowFlags_NoScrollWithMouse
	no_collapse                 = C.ImGuiWindowFlags_NoCollapse
	always_auto_resize          = C.ImGuiWindowFlags_AlwaysAutoResize
	no_background               = C.ImGuiWindowFlags_NoBackground
	no_saved_settings           = C.ImGuiWindowFlags_NoSavedSettings
	no_mouse_inputs             = C.ImGuiWindowFlags_NoMouseInputs
	menu_bar                    = C.ImGuiWindowFlags_MenuBar
	horizontal_scrollbar        = C.ImGuiWindowFlags_HorizontalScrollbar
	no_focus_on_appearing       = C.ImGuiWindowFlags_NoFocusOnAppearing
	no_bring_to_front_on_focus  = C.ImGuiWindowFlags_NoBringToFrontOnFocus
	always_vertical_scrollbar   = C.ImGuiWindowFlags_AlwaysVerticalScrollbar
	always_horizontal_scrollbar = C.ImGuiWindowFlags_AlwaysHorizontalScrollbar
	no_nav_inputs               = C.ImGuiWindowFlags_NoNavInputs
	no_nav_focus                = C.ImGuiWindowFlags_NoNavFocus
	unsaved_document            = C.ImGuiWindowFlags_UnsavedDocument
	no_docking                  = C.ImGuiWindowFlags_NoDocking
	no_nav                      = C.ImGuiWindowFlags_NoNavInputs | C.ImGuiWindowFlags_NoNavFocus
	no_decoration               = C.ImGuiWindowFlags_NoTitleBar | C.ImGuiWindowFlags_NoResize | C.ImGuiWindowFlags_NoScrollbar | C.ImGuiWindowFlags_NoCollapse
	no_inputs                   = C.ImGuiWindowFlags_NoMouseInputs | C.ImGuiWindowFlags_NoNavInputs | C.ImGuiWindowFlags_NoNavFocus
	child_window                = C.ImGuiWindowFlags_ChildWindow
	tooltip                     = C.ImGuiWindowFlags_Tooltip
	popup                       = C.ImGuiWindowFlags_Popup
	modal                       = C.ImGuiWindowFlags_Modal
	child_menu                  = C.ImGuiWindowFlags_ChildMenu
	dock_node_host              = C.ImGuiWindowFlags_DockNodeHost
}
