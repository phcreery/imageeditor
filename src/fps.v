module main

import time
import arrays
import math

struct FrameGovernor {
mut:
	frame_sw time.StopWatch = time.new_stopwatch()
pub mut:
	target_fps f64
	fps        f64
	duty_cycle f64

	fps_history  []f32 = []f32{len: 100, init: 0}
	duty_history []f32 = []f32{len: 100, init: 0}
}

fn (mut fg FrameGovernor) begin_frame() {
	fg.frame_sw.restart()
}

fn (mut fg FrameGovernor) sleep_remaining() {
	total_frame_ms := f64(fg.frame_sw.elapsed().milliseconds())
	target_frame_ms := 1000.0 / fg.target_fps
	sleep_time := math.max(0.0, target_frame_ms - total_frame_ms)
	if fg.target_fps > 0.0 && total_frame_ms < target_frame_ms {
		time.sleep(sleep_time * time.millisecond)
	}
	fg.fps = 1.0 / ((total_frame_ms + sleep_time) / 1000.0)
	fg.duty_cycle = total_frame_ms / target_frame_ms

	// update history
	arrays.rotate_right(mut &fg.fps_history, 1)
	fg.fps_history[0] = f32(fg.fps)
	arrays.rotate_right(mut &fg.duty_history, 1)
	fg.duty_history[0] = f32(fg.duty_cycle)
}

fn (fg FrameGovernor) fps_max() f64 {
	return arrays.max(fg.fps_history) or { 0.0 }
}

fn (fg FrameGovernor) fps_min() f64 {
	return arrays.min(fg.fps_history) or { 0.0 }
}
