module edit

// import processing.image
import processing
import processing.bench
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
	// make new_img a copy of img
	new_img.data = img.data

	mut benchmark_total := bench.Benchmark.new('Total')

	// process edits
	for mut edit in pipeline.edits {
		if edit.enabled {
			mut benchmark_edit := bench.Benchmark.new(edit.name)
			edit.process(mut pipeline.backend, img, mut new_img)
			benchmark_edit.finish()
		}
	}

	benchmark_total.finish()

	pipeline.dirty = false
}
