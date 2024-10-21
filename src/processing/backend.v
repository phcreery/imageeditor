module processing

// import processing.image
import cl
import imageio

interface Backend {
	name    string
	status  string
	version string
mut:
	init()
	shutdown()

	// edits
	invert(img imageio.Image, mut new_img imageio.Image)
}

pub fn Backend.new() Backend {
	return cl.create_backend_cl()
}
