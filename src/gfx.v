module main

import sokol.gfx
import sokol.sgl
import arrays
import math

const max_scale = 8.0
const min_scale = 0.05

@[heap]
struct GfxCheckerboard {
pub mut:
	image   gfx.Image
	sampler gfx.Sampler
}

@[heap]
struct GfxImage {
pub mut:
	image   gfx.Image
	sampler gfx.Sampler

	// pipeline gfx.Pipeline
	pipeline sgl.Pipeline
	width    f32
	height   f32
	scale    f32
	offset   Offset
}

fn (mut image GfxImage) reset_params() {
	image.scale = 0.1
	image.offset.x = 0.0
	image.offset.y = 0.0
}

fn (mut image GfxImage) move(dx f32, dy f32) {
	image.offset.x += (dx / image.scale)
	image.offset.y += (dy / image.scale)
}

fn (mut image GfxImage) scale(d f32) {
	image.scale = image.scale * f32(math.exp(d))
	if image.scale > max_scale {
		image.scale = max_scale
	} else if image.scale < min_scale {
		image.scale = min_scale
	}
}

fn init_image(mut state AppState) {
	// a sampler object for nearest mag filter and linear min filter
	sampler_desc := &gfx.SamplerDesc{
		mag_filter: gfx.Filter.nearest
		min_filter: gfx.Filter.linear
		wrap_u:     gfx.Wrap.clamp_to_edge
		wrap_v:     gfx.Wrap.clamp_to_edge
	}

	// create a pipeline object with alpha blending for rendering the loaded image
	mut pipeline_desc := gfx.PipelineDesc{}
	unsafe { vmemset(&pipeline_desc, 0, int(sizeof(pipeline_desc))) }
	pipeline_desc.colors[0] = gfx.ColorTargetState{
		// write_mask: gfx.ColorMask.rgb
		blend: gfx.BlendState{
			enabled:        true
			src_factor_rgb: gfx.BlendFactor.src_alpha
			dst_factor_rgb: gfx.BlendFactor.one_minus_src_alpha
		}
	}

	state.rendered_image.sampler = gfx.make_sampler(sampler_desc)
	dump(state.rendered_image.sampler)
	state.rendered_image.pipeline = sgl.make_pipeline(&pipeline_desc)

	// state.image.pipeline = gfx.make_pipeline(&pipeline_desc)
}

fn init_bg(mut state AppState) {
	// texture and sampler for rendering checkboard background
	mut pixels := [][]u32{len: 4, init: []u32{len: 4}}
	for y := 0; y < 4; y++ {
		for x := 0; x < 4; x++ {
			if (x ^ y) & 1 == 1 {
				pixels[y][x] = u32(0xFF666666)
			} else {
				pixels[y][x] = u32(0xFF333333)
			}
		}
	}

	mut tmp_imgdata := gfx.ImageData{}
	tmp_imgdata.subimage[0][0] = gfx.Range{
		ptr:  arrays.flatten[u32](pixels).data
		size: usize(arrays.flatten[u32](pixels).len * sizeof(pixels[0][0]))
	}

	// rgb8 deprecated
	mut image_desc := &gfx.ImageDesc{
		width:        4
		height:       4
		label:        &u8(0)
		pixel_format: gfx.PixelFormat.rgba8
		data:         tmp_imgdata
	}

	mut smp_desc := &gfx.SamplerDesc{
		min_filter: gfx.Filter.nearest
		mag_filter: gfx.Filter.nearest
		wrap_u:     gfx.Wrap.repeat
		wrap_v:     gfx.Wrap.repeat
	}

	state.checkerboard.image = gfx.make_image(image_desc)

	state.checkerboard.sampler = gfx.make_sampler(smp_desc)
}
