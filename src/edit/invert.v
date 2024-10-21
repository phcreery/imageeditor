module edit

import processing
import libs.cimgui
import imageio

pub struct Invert implements Edit {
pub mut:
	enabled bool
}

fn Invert.new() Invert {
	return Invert{
		enabled: false
	}
}

pub fn (invert Invert) process(mut backend processing.Backend, img imageio.Image, mut new_img imageio.Image) {
	new_img = backend.invert(img)
}

pub fn (mut invert Invert) draw() bool {
	changed := cimgui.checkbox('Invert', &invert.enabled)
	return changed
}
