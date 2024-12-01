module edit

import processing
import libs.cimgui
import common
import math
import processing.cpu

pub struct Temperature implements Edit {
	name            string                = 'Temperature'
	cs_from         common.ColorspaceType = .rgb
	cs_to           common.ColorspaceType = .rgb
	needed_backends []common.BackendID    = [common.BackendID.cpu]
pub mut:
	enabled     bool
	temperature f32             = 1000
	amount      f32             = 1
	dc          DebouncedChange = DebouncedChange{}
}

pub fn (mut temp Temperature) draw() bool {
	mut changed := false

	changed ||= cimgui.ig_checkbox(temp.name.str, &temp.enabled)

	cimgui.ig_push_id_str('Temp_Slider'.str)
	changed ||= cimgui.ig_slider_float('Temp'.str, &temp.temperature, 1000, 40000.0, '%.0f K'.str,
		.im_gui_slider_flags_none)

	// cimgui.ig_same_line(0, 10)
	// cimgui.ig_text('Temperature'.str)
	cimgui.ig_pop_id()

	cimgui.ig_push_id_str('Amount_Slider'.str)
	changed ||= cimgui.ig_slider_float('Amount'.str, &temp.amount, 0, 1, '%.2f'.str, .im_gui_slider_flags_none)
	cimgui.ig_pop_id()

	return temp.dc.debounce(changed)
}

pub fn (temp Temperature) process(mut backend processing.Backend) {
	// backend.invert()
	if mut backend is cpu.BackendCPU {
		// backend.process_cpu()
		mut eb_cpu := unsafe { &ExternBackendCPU(backend) }
		eb_cpu.adjust_temp(temp.temperature, temp.amount)
	}
}

////////  CPU  //////////
type ExternBackendCPU = cpu.BackendCPU

// TODO: move elsewhere, maybe backends/cpu/common.v
pub fn clamp_rgbf64_to_rgbu8(c common.RGB) common.RGBu8 {
	return common.RGBu8{
		r: u8(math.clamp(c.r * 255, min_u8, max_u8))
		g: u8(math.clamp(c.g * 255, min_u8, max_u8))
		b: u8(math.clamp(c.b * 255, min_u8, max_u8))
	}
}

// TODO: move elsewhere
fn luminance(color common.RGB) f64 {
	fmin := math.min(math.min(color.r, color.g), color.b)
	fmax := math.max(math.max(color.r, color.g), color.b)
	return (fmax + fmin) / 2.0
}

// TODO: move elsewhere
fn hsl2rgb(hsl common.HSL) common.RGB {
	c := (1 - math.abs(2 * hsl.l - 1)) * hsl.s
	x := c * (1 - math.abs(math.fmod((hsl.h / 60), 2) - 1))
	m := hsl.l - c / 2
	mut rgb := common.RGB{
		r: 0
		g: 0
		b: 0
	}
	if hsl.h < 60 {
		rgb.r = c
		rgb.g = x
	} else if hsl.h < 120 {
		rgb.r = x
		rgb.g = c
	} else if hsl.h < 180 {
		rgb.g = c
		rgb.b = x
	} else if hsl.h < 240 {
		rgb.g = x
		rgb.b = c
	} else if hsl.h < 300 {
		rgb.r = x
		rgb.b = c
	} else {
		rgb.r = c
		rgb.b = x
	}
	rgb.r = rgb.r + m
	rgb.g = rgb.g + m
	rgb.b = rgb.b + m
	return rgb
}

// TODO: move elsewhere
fn rgb2hsl(rgb common.RGB) common.HSL {
	r := rgb.r
	g := rgb.g
	b := rgb.b
	max := math.max(r, math.max(g, b))
	min := math.min(r, math.min(g, b))
	c := max - min
	mut hue := 0.0
	if c == 0 {
		hue = 0
	} else {
		if max == r {
			segment := (g - b) / c
			mut shift := 0 / 60
			if segment < 0 {
				shift = 360 / 60
			}
			hue = segment + shift
		} else if max == g {
			segment := (b - r) / c
			shift := 120 / 60
			hue = segment + shift
		} else if max == b {
			segment := (r - g) / c
			shift := 240 / 60
			hue = segment + shift
		}
	}
	mut h := hue * 60

	// Make negative hues positive behind 360°
	if h < 0 {
		h = 360 + h
	}

	l := (max + min) / 2
	mut s := 0.0
	if c != 0 {
		s = c / (1 - math.abs(2 * l - 1))
	} else {
		s = 0
	}

	return common.HSL{
		h: h
		s: s
		l: l
	}
}

// TODO: move elsewhere
fn mix_colors(color1 common.RGB, color2 common.RGB, amount f64) common.RGB {
	// Mix two colors together
	// https://stackoverflow.com/questions/726549/algorithm-for-additive-color-mixing-for-rgb-values
	// https://registry.khronos.org/OpenGL-Refpages/gl4/html/mix.xhtml
	a := math.clamp(amount, 0, 1)
	r := color1.r * (1 - a) + color2.r * a
	g := color1.g * (1 - a) + color2.g * a
	b := color1.b * (1 - a) + color2.b * a
	return common.RGB{
		r: r
		g: g
		b: b
	}
}

fn adjust_temp(pixel common.RGB, temperature f64, amount f64) common.RGB {
	// adjust the temperature of the image
	// https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
	// https://www.shadertoy.com/view/lsSXW1

	// Temperature must be between 1000 and 40000
	temp := math.clamp(temperature, 1000, 40000) / 100
	mut r := f64(0)
	mut g := f64(0)
	mut b := f64(0)

	// this is for RGB 0-1
	if temp <= 66 {
		r = 1
		g = math.log(temp) * 0.39008157876901960784 - 0.63184144378862745098
	} else {
		t := temp - 60
		r = math.pow(t, -0.1332047592) * 1.29293618606274509804
		g = math.pow(t, -0.0755148492) * 1.12989086089529411765
	}

	if temp >= 66 {
		b = 1
	} else if temp <= 19 {
		b = 0
	} else {
		b = math.log(temp - 10) * 0.54320678911019607843 - 1.19625408914
	}

	color_temp := common.RGB{
		r: r
		g: g
		b: b
	}
	color_temp_times_pixel := common.RGB{
		r: pixel.r * color_temp.r
		g: pixel.g * color_temp.g
		b: pixel.b * color_temp.b
	}
	original_luminance := luminance(pixel)
	blended := mix_colors(pixel, color_temp_times_pixel, amount)
	mut result_hsl := rgb2hsl(blended)
	result_hsl.l = original_luminance
	result_rgb := hsl2rgb(result_hsl)
	return result_rgb

	// return color_temp
}

pub fn (mut backend ExternBackendCPU) adjust_temp(temperature f64, amount f64) {
	for y in 0 .. backend.image_device_current.height {
		for x in 0 .. backend.image_device_current.width {
			pixel_rgb := backend.image_device_current.get_pixel[common.RGB](x, y)
			temp_pixel_rgb := adjust_temp(pixel_rgb, temperature, amount)
			backend.image_device_next.set_pixel[common.RGB](x, y, temp_pixel_rgb)
		}
	}
	backend.swap_images()
}

////////  OpenCL  //////////

// process_cl()
// pub fn (invert Temperature) process(mut backend cl.BackendCL) {
// }
