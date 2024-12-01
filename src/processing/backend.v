module processing

import imageio
import common

pub interface Backend {
	name    string
	id      common.BackendID
	status  common.BackendStatus
	version string
mut:
	init()
	copy_host_to_device(image imageio.Image)
	copy_device_to_host(mut image imageio.Image)
	swap_images()
	shutdown()
}
