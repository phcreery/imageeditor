module cl

import os
import benchmark

const invert_color_kernel = os.read_file(os.join_path(root, 'kernels/invert.cl')) or { panic(err) }

pub fn (mut backend BackendCL) invert() {
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
