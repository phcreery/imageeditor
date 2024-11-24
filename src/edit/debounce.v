module edit

import time

const debounce_time = 200 * time.millisecond

pub struct DebouncedChange {
pub mut:
	should_toggle bool
	sw            time.StopWatch = time.new_stopwatch()
}

pub fn (mut debounce DebouncedChange) debounce(new_toggle bool) bool {
	if new_toggle {
		debounce.should_toggle = new_toggle
		debounce.sw.restart()
	}

	if debounce.sw.elapsed() > debounce_time && debounce.should_toggle {
		debounce.should_toggle = false
		return true
	} else {
		return false
	}
}
