module edit

// import processing.image
import processing
import imageio

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
	new_img.data = img.data

	// if pipeline.invert.enabled {
	// 	new_img = pipeline.backend.invert(img)
	// }
	for mut edit in pipeline.edits {
		if edit.enabled {
			edit.process(mut pipeline.backend, img, mut new_img)
		}
	}
	pipeline.dirty = false
}
