module edit

import processing
import libs.cimgui
import common
import os
import benchmark
import processing.cl

pub struct Invert implements Edit {
	name    string                = 'Invert'
	cs_from common.ColorspaceType = .rgb
	cs_to   common.ColorspaceType = .rgb
pub mut:
	enabled bool
}

pub fn (mut invert Invert) draw() bool {
	changed := cimgui.ig_checkbox('Invert'.str, &invert.enabled)
	return changed
}

pub fn (invert Invert) process(mut backend processing.Backend) {
	// backend.invert()
	if mut backend is cl.BackendCL {
		backend.invert()
	}
}

// process_cl()
// pub fn (invert Invert) process(mut backend cl.BackendCL) {
// 	backend.invert()
// }

// 	// backend.invert()
// }

////////  OpenCL  //////////
const invert_color_kernel = os.read_file(os.join_path(cl.root, 'kernels/invert.cl')) or {
	panic(err)
}

type ExternBackendCL = cl.BackendCL

pub fn (mut backend ExternBackendCL) invert() {
	mut b := benchmark.start()

	// add program source to device, get kernel
	backend.device.add_program(invert_color_kernel) or { panic(err) }
	b.measure('cl.invert() add program')
	k := backend.device.kernel('invert') or { panic(err) }
	b.measure('cl.invert() get kernel')

	// run kernel (global work size 16 and local work size 1)
	kernel_err := <-k.global(int(backend.image_device_current.bounds.width), int(backend.image_device_current.bounds.height))
		.local(1, 1).run(backend.image_device_current, backend.image_device_next)
	if kernel_err !is none {
		panic(kernel_err)
	}
	b.measure('cl.invert() run kernel')

	backend.swap_images()
}
