module edit

// import processing.image
import processing
import imageio
import benchmark
import processing.cl
import processing.cpu
import common
import arrays

// insp from darktable/src/develop/pixelpipe.h
enum PixelPipeType {
	none
	export
	full
	preview
	thumbnail
}

pub struct PixelPipeline {
pub mut:
	backends        []&processing.Backend
	type            PixelPipeType
	dirty           bool
	edits           []&Edit
	current_backend ?&processing.Backend
}

pub fn init_pixelpipeline() PixelPipeline {
	mut backends := []&processing.Backend{}
	backends << cpu.BackendCPU.new()
	backends << cl.BackendCL.new()

	mut edits := []&Edit{}
	edits << Invert{}
	edits << Temperature{}

	// see darktable/src/common/iop_order.c
	// 	 { { 1.0 }, "rawprepare", 0},
	//   { { 2.0 }, "invert", 0},
	//   { { 3.0f }, "temperature", 0},
	//   { { 4.0f }, "highlights", 0},
	//   { { 5.0f }, "cacorrect", 0},
	//   { { 6.0f }, "hotpixels", 0},
	//   { { 7.0f }, "rawdenoise", 0},
	//   { { 8.0f }, "demosaic", 0},
	//   { { 9.0f }, "denoiseprofile", 0},
	//   { {10.0f }, "bilateral", 0},
	//   { {11.0f }, "rotatepixels", 0},
	//   { {12.0f }, "scalepixels", 0},
	//   { {13.0f }, "lens", 0},
	//   { {13.5f }, "cacorrectrgb", 0}, // correct chromatic aberrations
	//                                   // after lens correction so that
	//                                   // lensfun does not reintroduce
	//                                   // chromatic aberrations when trying
	//                                   // to correct them
	//   { {14.0f }, "hazeremoval", 0},
	//   { {15.0f }, "ashift", 0},
	//   { {16.0f }, "flip", 0},
	//   { {16.5f }, "enlargecanvas", 0},
	//   { {16.7f }, "overlay", 0},
	//   { {17.0f }, "clipping", 0},
	//   { {18.0f }, "liquify", 0},
	//   { {19.0f }, "spots", 0},
	//   { {20.0f }, "retouch", 0},
	//   { {21.0f }, "exposure", 0},
	//   { {22.0f }, "mask_manager", 0},
	//   { {23.0f }, "tonemap", 0},
	//   { {24.0f }, "toneequal", 0},       // last module that need enlarged
	//                                      // roi_in
	//   { {24.5f }, "crop", 0},            // should go after all modules
	//                                      // that may need a wider roi_in
	//   { {25.0f }, "graduatednd", 0},
	//   { {26.0f }, "profile_gamma", 0},
	//   { {27.0f }, "equalizer", 0},
	//   { {28.0f }, "colorin", 0},
	//   { {28.5f }, "channelmixerrgb", 0},
	//   { {28.5f }, "diffuse", 0},
	//   { {28.5f }, "censorize", 0},
	//   { {28.5f }, "negadoctor", 0},      // Cineon film encoding comes
	//                                      // after scanner input color
	//                                      // profile
	//   { {28.5f }, "blurs", 0},           // physically-accurate blurs (motion and lens)
	//   { {28.5f }, "primaries", 0},
	//   { {29.0f }, "nlmeans", 0},         // signal processing (denoising)
	//                                      //    -> needs a signal as scene-referred as possible (even if it works in Lab)
	//   { {30.0f }, "colorchecker", 0},    // calibration to "neutral" exchange colour space
	//                                   //    -> improve colour calibration of colorin and reproductibility
	//                                   //    of further edits (styles etc.)
	//   { {31.0f }, "defringe", 0},        // desaturate fringes in Lab, so needs properly calibrated colours
	//                                   //    in order for chromaticity to be meaningful,
	//   { {32.0f }, "atrous", 0},          // frequential operation, needs a signal as scene-referred as possible to avoid halos
	//   { {33.0f }, "lowpass", 0},         // same
	//   { {34.0f }, "highpass", 0},        // same
	//   { {35.0f }, "sharpen", 0},         // same, worst than atrous in same use-case, less control overall

	//   { {37.0f }, "colortransfer", 0},   // probably better if source and destination colours are neutralized in the same
	//                                   //    colour exchange space, hence after colorin and colorcheckr,
	//                                   //    but apply after frequential ops in case it does non-linear witchcraft,
	//                                   //    just to be safe
	//   { {38.0f }, "colormapping", 0},    // same
	//   { {39.0f }, "channelmixer", 0},    // does exactly the same thing as colorin, aka RGB to RGB matrix conversion,
	//                                   //    but coefs are user-defined instead of calibrated and read from ICC profile.
	//                                   //    Really versatile yet under-used module, doing linear ops,
	//                                   //    very good in scene-referred workflow
	//   { {40.0f }, "basicadj", 0},        // module mixing view/model/control at once, usage should be discouraged
	//   { {41.0f }, "colorbalance", 0},    // scene-referred color manipulation
	//   { {41.2f }, "colorequal", 0},
	//   { {41.5f }, "colorbalancergb", 0},    // scene-referred color manipulation
	//   { {42.0f }, "rgbcurve", 0},        // really versatile way to edit colour in scene-referred and display-referred workflow
	//   { {43.0f }, "rgblevels", 0},       // same
	//   { {44.0f }, "basecurve", 0},       // conversion from scene-referred to display referred, reverse-engineered
	//                                   //    on camera JPEG default look
	//   { {45.0f }, "filmic", 0},          // same, but different (parametric) approach
	//   { {45.3f }, "sigmoid", 0},
	//   { {46.0f }, "filmicrgb", 0},       // same, upgraded
	//   { {36.0f }, "lut3d", 0},           // apply a creative style or film emulation, possibly non-linear
	//   { {47.0f }, "colisa", 0},          // edit contrast while damaging colour
	//   { {48.0f }, "tonecurve", 0},       // same
	//   { {49.0f }, "levels", 0},          // same
	//   { {50.0f }, "shadhi", 0},          // same
	//   { {51.0f }, "zonesystem", 0},      // same
	//   { {52.0f }, "globaltonemap", 0},   // same
	//   { {53.0f }, "relight", 0},         // flatten local contrast while pretending do add lightness
	//   { {54.0f }, "bilat", 0},           // improve clarity/local contrast after all the bad things we have done
	//                                   //    to it with tonemapping
	//   { {55.0f }, "colorcorrection", 0}, // now that the colours have been damaged by contrast manipulations,
	//                                   // try to recover them - global adjustment of white balance for shadows and highlights
	//   { {56.0f }, "colorcontrast", 0},   // adjust chrominance globally
	//   { {57.0f }, "velvia", 0},          // same
	//   { {58.0f }, "vibrance", 0},        // same, but more subtle
	//   { {60.0f }, "colorzones", 0},      // same, but locally
	//   { {61.0f }, "bloom", 0},           // creative module
	//   { {62.0f }, "colorize", 0},        // creative module
	//   { {63.0f }, "lowlight", 0},        // creative module
	//   { {64.0f }, "monochrome", 0},      // creative module
	//   { {65.0f }, "grain", 0},           // creative module
	//   { {66.0f }, "soften", 0},          // creative module
	//   { {67.0f }, "splittoning", 0},     // creative module
	//   { {68.0f }, "vignette", 0},        // creative module
	//   { {69.0f }, "colorreconstruct", 0},// try to salvage blown areas before ICC intents in LittleCMS2 do things with them.
	//   { {69.4f }, "finalscale", 0},
	//   { {70.0f }, "colorout", 0},
	//   { {71.0f }, "clahe", 0},
	//   { {73.0f }, "overexposed", 0},
	//   { {74.0f }, "rawoverexposed", 0},
	//   { {75.0f }, "dither", 0},
	//   { {76.0f }, "borders", 0},
	//   { {77.0f }, "watermark", 0},
	//   { {78.0f }, "gamma", 0},
	//
	return PixelPipeline{
		backends: backends
		edits:    edits
	}
}

// insp. by darktable/src/develop/pixelpipe_hb.c
pub fn (mut pixpipe PixelPipeline) process(img imageio.Image, mut new_img imageio.Image) {
	// make new_img a copy of img
	new_img.data = img.data // does this actually clone or just copy the reference?

	// don't process if no edits are enabled
	mut any_enabled := false
	for mut edit in pixpipe.edits {
		if edit.enabled {
			any_enabled = true
			break
		}
	}
	if !any_enabled {
		pixpipe.dirty = false
		return
	}

	pixpipe.current_backend = ?&processing.Backend(none)

	mut b := benchmark.start()

	// TODO: colorspace handling

	// process edits
	for mut edit in pixpipe.edits {
		if edit.enabled {
			// Strategize:

			// if the current backend is not supported by the edit, move the image to the supported backend
			mut needs_to_move := false
			if pixpipe.current_backend != none {
				if !edit.needed_backends.any(it == pixpipe.current_backend.id) {
					needs_to_move = true
					pixpipe.current_backend.copy_device_to_host(mut new_img)
				}
			} else {
				needs_to_move = true
			}

			if needs_to_move {
				println('edit does not support currently loaded backend, moving image to supported backend')

				// move image to supported backend
				new_backend_id := arrays.find_first(edit.needed_backends, fn [pixpipe] (needed_id common.BackendID) bool {
					return pixpipe.backends.any(fn [needed_id] (available &processing.Backend) bool {
						return available.id == needed_id
					})
				}) or { panic('no ready backend found') }

				// dump(new_backend_id)
				new_backend_idx := arrays.index_of_first(pixpipe.backends, fn [new_backend_id] (idx int, backend &processing.Backend) bool {
					return backend.id == new_backend_id
				})

				pixpipe.current_backend = pixpipe.backends[new_backend_idx]

				if pixpipe.current_backend != none {
					pixpipe.current_backend.copy_host_to_device(new_img)
					b.measure('pixelpipeline process copy_host_to_device ${pixpipe.current_backend.id}')
				}
			}

			////////// process edit //////////
			if pixpipe.current_backend != none {
				edit.process(mut pixpipe.current_backend)
				b.measure('process ${edit.name}')
			}
		}
	}

	if pixpipe.current_backend != none {
		pixpipe.current_backend.copy_device_to_host(mut new_img)
		b.measure('pixelpipeline process copy_device_to_host ${pixpipe.current_backend.id}')
	}
	pixpipe.dirty = false

	println(b.total_message('pixelpipeline process total'))
}

pub fn (mut pixpipe PixelPipeline) shutdown() {
	for mut backend in pixpipe.backends {
		backend.shutdown()
	}
}
