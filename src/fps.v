module main

import time
import arrays

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

fn (mut fg FrameGovernor) sleep_remaining(last_frame_ms f64) {
	total_frame_ms := f64(fg.frame_sw.elapsed().microseconds()) / 1000.0
	fg.frame_sw.restart()
	if fg.target_fps > 0.0 {
		target_frame_ms := 1000.0 / fg.target_fps
		if last_frame_ms < target_frame_ms {
			time.sleep((target_frame_ms - last_frame_ms) * 1000000.0)
		}
	}
	fg.fps = 1.0 / (total_frame_ms / 1000.0)
	fg.duty_cycle = last_frame_ms / (1000.0 / fg.target_fps)

	// update history
	arrays.rotate_right(mut &fg.fps_history, 1)
	fg.fps_history[0] = f32(fg.fps)
	arrays.rotate_right(mut &fg.duty_history, 1)
	fg.duty_history[0] = f32(fg.duty_cycle)

	$if debug {
		eprintln('fps: ${thefps:5.1f} | last frame took: ${last_frame_ms:6.3f}ms | frame: ${game.frame:6} ')
	}
}
