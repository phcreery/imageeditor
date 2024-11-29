module processing

import cl
import imageio
import common

pub interface Backend {
	name    string
	mem_ctx common.DeviceMemoryContext
	status  string
	version string
mut:
	init()
	copy_host_to_device(image imageio.Image)
	copy_device_to_host(mut image imageio.Image)
	swap_images()
	shutdown()

	// edits
	// invert()
}

// pub fn Backend.new() Backend {
// 	return cl.create_backend_cl()
// }
