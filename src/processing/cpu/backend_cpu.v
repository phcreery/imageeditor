module cpu

import imageio
import common

pub struct BackendCPU {
mut:
	image_device_current &imageio.Image = &imageio.Image{}
	image_device_next    &imageio.Image = &imageio.Image{}
pub:
	name    string               = 'CPU'
	id      common.BackendID     = .cpu
	status  common.BackendStatus = .notready
	version string               = '0.1'
}

pub fn BackendCPU.new() &BackendCPU {
	return &BackendCPU{
		status: common.BackendStatus.ready
	}
}

pub fn (mut backend BackendCPU) init() {
	// init device
}

pub fn (mut backend BackendCPU) copy_host_to_device(image imageio.Image) {
	backend.image_device_current = &imageio.Image{
		width:  image.width
		height: image.height

		// TODO: improve, this is slow
		data: image.data.clone()
	}

	backend.image_device_next = &imageio.Image{
		width:  image.width
		height: image.height

		// TODO: improve, this is slow
		data: image.data.clone()
	}
}

pub fn (mut backend BackendCPU) swap_images() {
	tmp := backend.image_device_current
	backend.image_device_current = backend.image_device_next
	backend.image_device_next = tmp
}

pub fn (mut backend BackendCPU) copy_device_to_host(mut image imageio.Image) {
	image = backend.image_device_current
}

pub fn (mut backend BackendCPU) shutdown() {
	// backend.image_device_current.release() or { panic(err) }
	// backend.image_device_next.release() or { panic(err) }
	// backend.device.release() or { panic(err) }
}
