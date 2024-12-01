module edit

import processing
import libs.cimgui
import common
import processing.cl

pub struct Temperature implements Edit {
	name    string                = 'Temperature'
	cs_from common.ColorspaceType = .none
	cs_to   common.ColorspaceType = .none
pub mut:
	enabled bool

	value f32             = 0.5
	dc    DebouncedChange = DebouncedChange{}
}

pub fn (temp Temperature) process(mut backend processing.Backend) {
	// backend.invert()
}

// pub fn (temp Temperature) process_cpu(mut backend processing.Backend) {
// 	for yy in 0 .. backend..image.height {
// 		for xx in 0 .. backend.image.width {
// 			pixel := img.get_pixel(xx, yy)
// 			pixel_rgbf64 := rgbu8_to_rgbf64(pixel)
// 			new_pixel_rgbf64 := modifier(pixel_rgbf64)
// 			clamped_rgb := clamp_rgbf64_to_rgbu8(new_pixel_rgbf64)
// 			newimg.set_pixel(xx, yy, clamped_rgb)
// 		}
// 	}
// 	return newimg
// }

// process_cl()
// pub fn (invert Temperature) process(mut backend cl.BackendCL) {
// 	backend.invert()
// }
pub fn (mut temp Temperature) draw() bool {
	mut changed := false

	changed ||= cimgui.ig_checkbox(temp.name.str, &temp.enabled)

	cimgui.ig_push_id_str('Temp_Slider'.str)
	changed ||= cimgui.ig_slider_float(temp.name.str, &temp.value, 0.0, 1.0, '%.3f'.str,
		.im_gui_slider_flags_none)

	// cimgui.ig_same_line(0, 10)
	// cimgui.ig_text('Temperature'.str)
	cimgui.ig_pop_id()

	return temp.dc.debounce(changed)
}
