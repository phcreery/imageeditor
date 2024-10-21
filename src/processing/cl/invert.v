module cl

import arrays
import os
import stbi
import imageio

const invert_color_kernel = os.read_file(os.join_path(root, 'kernels/invert.cl')) or { panic(err) }

pub fn (mut backend BackendCL) invert(image imageio.Image, mut new_image imageio.Image) {
	// println('first 4 pixels of original image: ${image.data[0..16]}')

	// Create image buffer (image2d_t) to read_only
	stbi_img := stbi.Image{
		width:       image.width
		height:      image.height
		nr_channels: 4
		data:        image.data.data
	}

	mut vcl_image := backend.device.from_image(stbi_img) or { panic(err) }
	defer {
		vcl_image.release() or { panic(err) }
	}

	// Create image buffer (image2d_t) to write_only
	// mut inverted_img := device.image(.rgba, width: img.bounds.width, height: img.bounds.height)!
	mut inverted_vcl_image := backend.device.from_image(stbi_img) or { panic(err) }
	defer {
		inverted_vcl_image.release() or { panic(err) }
	}

	// add program source to device, get kernel
	backend.device.add_program(invert_color_kernel) or { panic(err) }
	k := backend.device.kernel('invert') or { panic(err) }

	// run kernel (global work size 16 and local work size 1)
	kernel_err := <-k.global(int(vcl_image.bounds.width), int(vcl_image.bounds.height))
		.local(1, 1).run(vcl_image, inverted_vcl_image)
	if kernel_err !is none {
		panic(kernel_err)
	}

	next_inverted_img := inverted_vcl_image.data() or { panic(err) }
	mut data := unsafe { arrays.carray_to_varray[u8](next_inverted_img.data, next_inverted_img.width * next_inverted_img.height * 4) }

	// println('first 4 pixels of inverted image: ${data[0..16]}')
	new_image.data = data

	// return new_image
}
