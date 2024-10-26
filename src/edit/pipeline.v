module edit

// import processing.image
import processing
import imageio
import benchmark

pub struct Pipeline {
pub mut:
	backend processing.Backend
	dirty   bool = true
	edits   []&Edit
}

pub fn init_pipeline() Pipeline {
	mut edits := []&Edit{}
	edits << Invert.new()
	return Pipeline{
		backend: processing.Backend.new()
		edits:   edits
	}
}

pub fn (mut pipeline Pipeline) process(img imageio.Image, mut new_img imageio.Image) {
	// make new_img a copy of img
	new_img.data = img.data

	mut b := benchmark.start()

	// don't process if no edits are enabled
	mut any_enabled := false
	for mut edit in pipeline.edits {
		if edit.enabled {
			any_enabled = true
			break
		}
	}
	if !any_enabled {
		pipeline.dirty = false
		return
	}

	pipeline.backend.load_image(img)
	b.measure('load_image')

	// process edits
	for mut edit in pipeline.edits {
		if edit.enabled {
			edit.process(mut pipeline.backend)
			b.measure('process ${edit.name}')
		}
	}

	pipeline.backend.read_image(mut new_img)
	b.measure('read_image')

	pipeline.dirty = false
}
