module main

import sokol.gfx
import sokol.sgl
import arrays
import math
import imageio

const max_scale = 8.0
const min_scale = 0.05

struct Offset {
pub mut:
	x f32
	y f32
}

@[heap]
struct GfxTexture {
pub mut:
	image   gfx.Image
	sampler gfx.Sampler
}

@[heap]
struct GfxImage {
pub mut:
	image    gfx.Image
	sampler  gfx.Sampler
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

fn GfxImage.new() GfxImage {
	sampler_desc := &gfx.SamplerDesc{
		mag_filter: gfx.Filter.nearest
		min_filter: gfx.Filter.linear
		wrap_u:     gfx.Wrap.clamp_to_edge
		wrap_v:     gfx.Wrap.clamp_to_edge
	}

	// TODO: do we need a pipeline?
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

	return GfxImage{
		image:    gfx.Image{}
		sampler:  gfx.make_sampler(sampler_desc)
		pipeline: sgl.make_pipeline(&pipeline_desc)
		width:    0.0
		height:   0.0
		scale:    1
		offset:   Offset{
			x: 0.0
			y: 0.0
		}
	}
}

// Create a new image from an imageio.Image.
// NOTE: this will create a dynamic image
// this means the image data can be updated
// but it will not be loaded on create()
// use update() to load the image data
fn (mut gfx_image GfxImage) create(image imageio.Image) {
	if gfx_image.image.id != 0 { // SG_INVALID_ID
		gfx.destroy_image(gfx_image.image)
		gfx_image.image.id = 0
	}

	gfx_image.width = f32(image.width)
	gfx_image.height = f32(image.height)

	image_desc := gfx.ImageDesc{
		width:        image.width
		height:       image.height
		pixel_format: gfx.PixelFormat.rgba8
		usage:        gfx.Usage.dynamic
	}

	gfx_image.image = gfx.make_image(&image_desc)
}

fn (mut gfx_image GfxImage) update(image imageio.Image) {
	gfx_image.width = f32(image.width)
	gfx_image.height = f32(image.height)

	mut image_data := gfx.ImageData{}
	image_data.subimage[0][0] = gfx.Range{
		ptr:  image.data.data
		size: usize(image.width * image.height * 4)
	}

	gfx.update_image(gfx_image.image, &image_data)
}

fn (mut gfx_image GfxImage) draw() {
	// draw actual image
	x0 := ((-gfx_image.width * 0.5) * gfx_image.scale) + (gfx_image.offset.x * gfx_image.scale)
	x1 := x0 + (gfx_image.width * gfx_image.scale)
	y0 := ((-gfx_image.height * 0.5) * gfx_image.scale) + (gfx_image.offset.y * gfx_image.scale)
	y1 := y0 + (gfx_image.height * gfx_image.scale)

	sgl.texture(gfx_image.image, gfx_image.sampler)
	sgl.load_pipeline(gfx_image.pipeline)

	// sgl.c3f(state.center_image_rendered.color.r, state.center_image_rendered.color.g, state.center_image_rendered.color.b)
	sgl.begin_quads()
	sgl.v2f_t2f(x0, y0, 0.0, 0.0)
	sgl.v2f_t2f(x1, y0, 1.0, 0.0)
	sgl.v2f_t2f(x1, y1, 1.0, 1.0)
	sgl.v2f_t2f(x0, y1, 0.0, 1.0)
	sgl.end()
}

fn GfxTexture.new_checkerboard() GfxTexture {
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

	return GfxTexture{
		image:   gfx.make_image(image_desc)
		sampler: gfx.make_sampler(smp_desc)
	}
}

fn (mut texture GfxTexture) draw_checkerboard(disp_w f32, disp_h f32) {
	// draw checkerboard background
	x0 := -disp_w * 0.5
	x1 := x0 + disp_w
	y0 := -disp_h * 0.5
	y1 := y0 + disp_h

	u0 := (x0 / 32.0)
	u1 := (x1 / 32.0)
	v0 := (y0 / 32.0)
	v1 := (y1 / 32.0)

	sgl.texture(texture.image, texture.sampler)
	sgl.begin_quads()
	sgl.v2f_t2f(x0, y0, u0, v0)
	sgl.v2f_t2f(x1, y0, u1, v0)
	sgl.v2f_t2f(x1, y1, u1, v1)
	sgl.v2f_t2f(x0, y1, u0, v1)
	sgl.end()
}
