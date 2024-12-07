module image

// #flag -I @VMODROOT/thirdparty/stb
// #define STB_IMAGE_IMPLEMENTATION
// #include "stb_image.h"

//-----------------------------------------------------------------------------
//
// Utility functions
//
//-----------------------------------------------------------------------------
fn C.stbi_image_free(retval_from_stbi_load &u8)

pub fn stbi_image_free(retval_from_stbi_load &u8) {
	C.stbi_image_free(retval_from_stbi_load)
}

// pub fn (img &Image) free() {
// 	C.stbi_image_free(img.data)
// }

//-----------------------------------------------------------------------------
//
// Load functions
//
//-----------------------------------------------------------------------------
fn C.stbi_load(filename &char, x &int, y &int, channels_in_file &int, desired_channels int) &u8

pub fn stbi_load(filename string, x &int, y &int, channels_in_file &int, desired_channels int) &u8 {
	return C.stbi_load(&char(filename.str), x, y, channels_in_file, desired_channels)
}

fn C.stbi_load_from_file(f voidptr, x &int, y &int, channels_in_file &int, desired_channels int) &u8

pub fn stbi_load_from_file(f voidptr, x &int, y &int, channels_in_file &int, desired_channels int) &u8 {
	return C.stbi_load_from_file(f, x, y, channels_in_file, desired_channels)
}

fn C.stbi_load_from_memory(buffer &u8, len int, x &int, y &int, channels_in_file &int, desired_channels int) &u8

pub fn stbi_load_from_memory(buffer &u8, len int, x &int, y &int, channels_in_file &int, desired_channels int) &u8 {
	return C.stbi_load_from_memory(buffer, len, x, y, channels_in_file, desired_channels)
}

/*

@[params]
pub struct LoadParams {
pub:
	desired_channels int = C.STBI_rgb_alpha // 4 by default (RGBA); desired_channels is the number of color channels, that will be used for representing the image in memory. If set to 0, stbi will figure out the number of channels, based on the original image data.
}

// load loads an image from `path`
// If you do not pass desired_channels: explicitly, it will default to 4 (RGBA),
// The image, will get converted into that internal format, no matter what it was on disk.
// Use desired_channels:0, if you need to keep the channels of the image on disk.
//    Note that displaying such an image, with gg/sokol later, can be a problem.
//    Converting/resizing it, should work fine though.
pub fn load(path string, params LoadParams) !Image {
	ext := path.all_after_last('.')
	mut res := Image{
		ok:          true
		ext:         ext
		nr_channels: params.desired_channels
	}
	res.data = C.stbi_load(&char(path.str), &res.width, &res.height, &res.original_nr_channels,
		params.desired_channels)
	if params.desired_channels == 0 {
		res.nr_channels = res.original_nr_channels
	}
	if isnil(res.data) {
		return error('stbi_image failed to load from "${path}"')
	}
	return res
}

// load_from_memory load an image from a memory buffer
// If you do not pass desired_channels: explicitly, it will default to 4 (RGBA),
// and the image will get converted into that internal format, no matter what it was originally.
// Use desired_channels:0, if you need to keep the channels of the image as they were.
//    Note that displaying such an image, with gg/sokol later, can be a problem.
//    Converting/resizing it, should work fine though.
pub fn load_from_memory(buf &u8, bufsize int, params LoadParams) !Image {
	mut res := Image{
		ok:          true
		nr_channels: params.desired_channels
	}
	res.data = C.stbi_load_from_memory(buf, bufsize, &res.width, &res.height, &res.original_nr_channels,
		params.desired_channels)
	if params.desired_channels == 0 {
		res.nr_channels = res.original_nr_channels
	}
	if isnil(res.data) {
		return error('stbi_image failed to load from memory')
	}
	return res
}
*/
