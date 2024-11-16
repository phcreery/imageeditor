module edit

import processing
import libs.cimgui

pub struct Invert implements Edit {
	name string = 'Invert'
pub mut:
	enabled bool
}

fn Invert.new() Invert {
	return Invert{
		enabled: false
	}
}

pub fn (invert Invert) process(mut backend processing.Backend) {
	backend.invert()
}

pub fn (mut invert Invert) draw() bool {
	changed := cimgui.ig_checkbox('Invert'.str, &invert.enabled)
	return changed
}
