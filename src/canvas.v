module main

import math
import sokol.sgl

const max_scale = 8.0
const min_scale = 0.05

fn move(mut state AppState, dx f32, dy f32) {
	state.image.offset.x += (dx / state.image.scale)
	state.image.offset.y += (dy / state.image.scale)
}

fn scale(mut state AppState, d f32) {
	state.image.scale = state.image.scale * f32(math.exp(d))
	if state.image.scale > max_scale {
		state.image.scale = max_scale
	} else if state.image.scale < min_scale {
		state.image.scale = min_scale
	}
}


fn canvas_draw_checkerboard(state AppState, disp_w f32, disp_h f32) {
	// draw checkerboard background
	x0 := -disp_w * 0.5
	x1 := x0 + disp_w
	y0 := -disp_h * 0.5
	y1 := y0 + disp_h

	u0 := (x0 / 32.0)
	u1 := (x1 / 32.0)
	v0 := (y0 / 32.0)
	v1 := (y1 / 32.0)

	sgl.texture(state.checkerboard.image, state.checkerboard.sampler)
	sgl.begin_quads()
	sgl.v2f_t2f(x0, y0, u0, v0)
	sgl.v2f_t2f(x1, y0, u1, v0)
	sgl.v2f_t2f(x1, y1, u1, v1)
	sgl.v2f_t2f(x0, y1, u0, v1)
	sgl.end()
}

fn canvas_draw_image(state AppState) {
	
	// draw actual image
	x0_img := ((-state.image.width * 0.5) * state.image.scale) +
		(state.image.offset.x * state.image.scale)
	x1_img := x0_img + (state.image.width * state.image.scale)
	y0_img := ((-state.image.height * 0.5) * state.image.scale) +
		(state.image.offset.y * state.image.scale)
	y1_img := y0_img + (state.image.height * state.image.scale)

	sgl.texture(state.image.image, state.image.sampler)
	sgl.load_pipeline(state.image.pipeline)
	sgl.c3f(state.image.color.r, state.image.color.g, state.image.color.b)
	sgl.begin_quads()
	sgl.v2f_t2f(x0_img, y0_img, 0.0, 0.0)
	sgl.v2f_t2f(x1_img, y0_img, 1.0, 0.0)
	sgl.v2f_t2f(x1_img, y1_img, 1.0, 1.0)
	sgl.v2f_t2f(x0_img, y1_img, 0.0, 1.0)
	sgl.end()
}