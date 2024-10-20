module cl

import vsl.vcl
import os

// pub struct Image {
// 	width       int
// 	height      int
// 	nr_channels int
// mut:
// 	data []u8
// }

// pub interface IImage {
// 	width       int
// 	height      int
// 	nr_channels int
// mut:
// 	data []u8
// }
pub struct BackendCL {
mut:
	device &vcl.Device
pub:
	name    string = 'OpenCL'
	version string
	status  string
}

const root = os.dir(@FILE)

pub fn create_backend_cl() BackendCL {
	mut device := vcl.get_default_device() or { panic(err) }
	return BackendCL{
		status:  'ok'
		device:  device
		version: device.open_clc_version() or { panic(err) }
	}
}

pub fn (mut backend BackendCL) init() {
	return
}

pub fn (mut backend BackendCL) shutdown() {
	backend.device.release() or { panic(err) }
}
