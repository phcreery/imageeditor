module edit

import processing
import libs.cimgui

pub struct Invert implements Edit {
pub mut:
	enabled bool
}

pub fn (invert Invert) process(img IImage) IImage {
	// TODO: implement
	return img
}

pub fn (invert Invert) draw() bool {
	return cimgui.checkbox('Invert', &invert.enabled)
}
