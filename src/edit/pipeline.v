module edit

// import processing.image
import processing
import imageio
import benchmark
import processing.cl

// insp from darktable/src/develop/pixelpipe.h
enum PixelPipeType {
	none
	export
	full
	preview
	thumbnail
}

pub struct PixelPipeline {
pub mut:
	// backend processing.Backend = processing.Backend.new()
	// backend cl.BackendCL = cl.create_backend_cl()
	// backend cl.BackendCL = cl.BackendCL.new()
	backend processing.Backend = processing.Backend(cl.BackendCL.new())

	// cl.BackendCL.new()
	// backend_cpu &processing.Backend
	type  PixelPipeType
	dirty bool
	edits []&Edit
}

pub fn init_pixelpipeline() PixelPipeline {
	// mut backends := []&processing.Backend{}
	// backends << processing.Backend.new()

	// see darktable/src/common/iop_order.c
	mut edits := []&Edit{}
	edits << Invert{}
	edits << Temperature{}
	return PixelPipeline{
		edits: edits
	}
}

// insp. by darktable/src/develop/pixelpipe_hb.c
pub fn (mut pixpipe PixelPipeline) process(img imageio.Image, mut new_img imageio.Image) {
	// make new_img a copy of img
	new_img.data = img.data // does this actually clone or just copy the reference?

	// don't process if no edits are enabled
	mut any_enabled := false
	for mut edit in pixpipe.edits {
		if edit.enabled {
			any_enabled = true
			break
		}
	}
	if !any_enabled {
		pixpipe.dirty = false
		return
	}

	mut b := benchmark.start()

	// TODO: colorspace handling

	// TODO: memory manage per edit
	pixpipe.backend.copy_host_to_device(img)
	b.measure('pixelpipeline process copy_host_to_device')

	// process edits
	for mut edit in pixpipe.edits {
		if edit.enabled {
			edit.process(mut pixpipe.backend)
			b.measure('process ${edit.name}')
		}
	}

	// TODO: memory manage per edit
	pixpipe.backend.copy_device_to_host(mut new_img)
	b.measure('pixelpipeline process copy_device_to_host')

	pixpipe.dirty = false

	println(b.total_message('pixelpipeline process'))
}

pub fn (mut pixpipe PixelPipeline) shutdown() {
	pixpipe.backend.shutdown()
}
