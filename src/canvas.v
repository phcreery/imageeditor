module main

import sokol.sgl

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
	x0 := ((-state.rendered_image.width * 0.5) * state.rendered_image.scale) +
		(state.rendered_image.offset.x * state.rendered_image.scale)
	x1 := x0 + (state.rendered_image.width * state.rendered_image.scale)
	y0 := ((-state.rendered_image.height * 0.5) * state.rendered_image.scale) +
		(state.rendered_image.offset.y * state.rendered_image.scale)
	y1 := y0 + (state.rendered_image.height * state.rendered_image.scale)

	sgl.texture(state.rendered_image.image, state.rendered_image.sampler)
	sgl.load_pipeline(state.rendered_image.pipeline)
	// sgl.c3f(state.rendered_image.color.r, state.rendered_image.color.g, state.rendered_image.color.b)
	sgl.begin_quads()
	sgl.v2f_t2f(x0, y0, 0.0, 0.0)
	sgl.v2f_t2f(x1, y0, 1.0, 0.0)
	sgl.v2f_t2f(x1, y1, 1.0, 1.0)
	sgl.v2f_t2f(x0, y1, 0.0, 1.0)
	sgl.end()
}
