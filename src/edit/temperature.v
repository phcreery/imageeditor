module edit

import processing
import libs.cimgui
import time

const debounce_time = 200 * time.millisecond

pub struct DebouncedChange {
pub mut:
	should_toggle bool
	sw            time.StopWatch = time.new_stopwatch()
}

pub fn (mut debounce DebouncedChange) debounce(new_toggle bool) bool {
	if new_toggle {
		debounce.should_toggle = new_toggle
		debounce.sw.restart()
	}

	if debounce.sw.elapsed() > debounce_time && debounce.should_toggle {
		debounce.should_toggle = false
		return true
	} else {
		return false
	}
}

pub struct Temperature implements Edit {
	name string = 'Temperature'
pub mut:
	enabled bool

	value f32 = 0.5
	dc    DebouncedChange
}

fn Temperature.new() Temperature {
	return Temperature{
		enabled: false
		dc:      DebouncedChange{
			should_toggle: false
		}
	}
}

pub fn (temp Temperature) process(mut backend processing.Backend) {
	// backend.invert()
}

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
