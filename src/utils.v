module main

import math
import common

pub fn clamp_rgbf64_to_rgbu8(c common.RGB) common.RGBu8 {
	return common.RGBu8{
		r: u8(math.clamp(c.r * 255, min_u8, max_u8))
		g: u8(math.clamp(c.g * 255, min_u8, max_u8))
		b: u8(math.clamp(c.b * 255, min_u8, max_u8))
	}
}

pub fn rgbu8_to_rgbf64(c common.RGBu8) common.RGB {
	return common.RGB{
		r: f64(c.r) / 255
		g: f64(c.g) / 255
		b: f64(c.b) / 255
	}
}
