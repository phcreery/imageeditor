module edit

// import processing.image
import processing
import imageio

pub struct Pipeline {
pub mut:
	backend processing.Backend
	dirty   bool = true
	invert  Invert
}

pub fn init_pipeline() Pipeline {
	return Pipeline{
		backend: processing.Backend.new()
		invert:  Invert{
			enabled: false
		}
	}
}

pub fn (mut pipeline Pipeline) process(img imageio.Image, mut new_img imageio.Image) {
	new_img.data = img.data
	if pipeline.invert.enabled {
		new_img = pipeline.backend.invert(img)
	}
}
