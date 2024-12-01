module cl

import vsl.vcl
import os
import stbi
import imageio
import arrays
import common

pub const root = os.dir(@VMODROOT)

pub struct BackendCL {
mut:
	device               &vcl.Device = unsafe { nil }
	image                imageio.Image
	image_device_current &vcl.Image = unsafe { nil }
	image_device_next    &vcl.Image = unsafe { nil }
pub:
	name    string               = 'OpenCL'
	id      common.BackendID     = .cl
	status  common.BackendStatus = .notready
	version string
}

pub fn BackendCL.new() &BackendCL {
	mut device := vcl.get_default_device() or { panic(err) }
	return &BackendCL{
		status:               .ready
		device:               device
		version:              device.open_clc_version() or { panic(err) }
		image_device_current: unsafe { nil }
		image_device_next:    unsafe { nil }
	}
}

pub fn (mut backend BackendCL) init() {
	// init OpenCL device
}

pub fn (mut backend BackendCL) copy_host_to_device(image imageio.Image) {
	// load image from host to device
	backend.image = image
	stbi_img := stbi.Image{
		width:       image.width
		height:      image.height
		nr_channels: 4
		data:        image.data.data
	}
	backend.image_device_current = backend.device.from_image(stbi_img) or { panic(err) }
	backend.image_device_next = backend.device.image(.rgba, width: image.width, height: image.height) or {
		panic(err)
	}
}

pub fn (mut backend BackendCL) copy_device_to_host(mut image imageio.Image) {
	// read image back from device to host
	processed_image := backend.image_device_current.data() or { panic(err) }

	// b.measure('get data')
	mut data := unsafe { arrays.carray_to_varray[u8](processed_image.data, processed_image.width * processed_image.height * 4) }

	// b.measure('convert data')
	image.data = data
}

pub fn (mut backend BackendCL) swap_images() {
	tmp := backend.image_device_current
	backend.image_device_current = backend.image_device_next
	backend.image_device_next = tmp
}

pub fn (mut backend BackendCL) shutdown() {
	backend.image_device_current.release() or { panic(err) }
	backend.image_device_next.release() or { panic(err) }
	backend.device.release() or { panic(err) }
}
