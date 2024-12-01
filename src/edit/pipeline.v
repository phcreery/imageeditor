module edit

// import processing.image
import processing
import imageio
import benchmark
import processing.cl
import processing.cpu
import common
import arrays

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
	backends        []&processing.Backend
	type            PixelPipeType
	dirty           bool
	edits           []&Edit
	current_backend ?&processing.Backend
}

pub fn init_pixelpipeline() PixelPipeline {
	mut backends := []&processing.Backend{}
	backends << cpu.BackendCPU.new()
	backends << cl.BackendCL.new()

	// see darktable/src/common/iop_order.c
	mut edits := []&Edit{}
	edits << Invert{}
	edits << Temperature{}
	return PixelPipeline{
		backends: backends
		edits:    edits
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

	pixpipe.current_backend = ?&processing.Backend(none)

	mut b := benchmark.start()

	// TODO: colorspace handling

	// process edits
	for mut edit in pixpipe.edits {
		if edit.enabled {
			// Strategize:

			// if the current backend is not supported by the edit, move the image to the supported backend
			mut needs_to_move := false
			if pixpipe.current_backend != none {
				if !edit.needed_backends.any(it == pixpipe.current_backend.id) {
					needs_to_move = true
					pixpipe.current_backend.copy_device_to_host(mut new_img)
				}
			} else {
				needs_to_move = true
			}

			if needs_to_move {
				println('edit does not support currently loaded backend, moving image to supported backend')

				// move image to supported backend
				new_backend_id := arrays.find_first(edit.needed_backends, fn [pixpipe] (needed_id common.BackendID) bool {
					return pixpipe.backends.any(fn [needed_id] (available &processing.Backend) bool {
						return available.id == needed_id
					})
				}) or { panic('no ready backend found') }

				// dump(new_backend_id)
				new_backend_idx := arrays.index_of_first(pixpipe.backends, fn [new_backend_id] (idx int, backend &processing.Backend) bool {
					return backend.id == new_backend_id
				})

				pixpipe.current_backend = pixpipe.backends[new_backend_idx]

				if pixpipe.current_backend != none {
					pixpipe.current_backend.copy_host_to_device(new_img)
					b.measure('pixelpipeline process copy_host_to_device ${pixpipe.current_backend.id}')
				}
			}

			////////// process edit //////////
			if pixpipe.current_backend != none {
				edit.process(mut pixpipe.current_backend)
				b.measure('process ${edit.name}')
			}
		}
	}

	if pixpipe.current_backend != none {
		pixpipe.current_backend.copy_device_to_host(mut new_img)
		b.measure('pixelpipeline process copy_device_to_host ${pixpipe.current_backend.id}')
	}
	pixpipe.dirty = false

	println(b.total_message('pixelpipeline process total'))
}

pub fn (mut pixpipe PixelPipeline) shutdown() {
	for mut backend in pixpipe.backends {
		backend.shutdown()
	}
}
