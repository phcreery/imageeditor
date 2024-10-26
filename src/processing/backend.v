module processing

import cl
import imageio

interface Backend {
	name    string
	status  string
	version string
mut:
	init()
	load_image(image imageio.Image)
	read_image(mut image imageio.Image)
	swap_images()
	shutdown()

	// edits
	invert()
}

pub fn Backend.new() Backend {
	return cl.create_backend_cl()
}
