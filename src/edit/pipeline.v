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

	// process edits
	for mut edit in pipeline.edits {
		if edit.enabled {
			edit.process(mut pipeline.backend, img, mut new_img)
			b.measure('process ${edit.name}')
		}
	}
	pipeline.dirty = false
}
