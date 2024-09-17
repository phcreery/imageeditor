module main

// import v.reflection as ref

// RGB values in the range [0, 255] (u8).
pub struct RGB {
mut:
	r u8
	g u8
	b u8
}

// RGB values in the range [0, 1] (f64).
struct RGBf64 {
mut:
	r f64
	g f64
	b f64
}

type PixelRepresenation = RGB | RGBf64

type PixelEditFn = fn (mut PixelRepresenation) PixelRepresenation

// type PixelEditFn = fn (mut RGB) RGB
// 	| fn (mut RGBf64) RGBf64
// 	| fn (mut RGB) RGBf64
// 	| fn (mut RGBf64) RGB

struct PixelEditStep {
pub mut:
	func PixelEditFn = unsafe { nil }
}

struct PixelEditPipeline {
pub mut:
	steps []PixelEditStep
}

fn (mut pipeline PixelEditPipeline) addstep(step PixelEditStep) {
	// pipeline.steps << unsafe { PixelEditFn(step) }
	pipeline.steps << step
}

fn (mut pipeline PixelEditPipeline) exec(mut pixel PixelRepresenation) PixelRepresenation {
	mut newpixel := pixel
	for step in pipeline.steps {
		dump(step)
		dump(newpixel)

		newpixel = step.func(mut newpixel)

		// dump(pix2)
		// dump(PixelRepresenation(pix).type_name()) // input type name
		// dump(pix2.type_name()) // output type name
		// dump(pix2.type_name() is RGB) // output type name
	}
	return newpixel
}

// A function from external library
fn pixfn1(mut pixel RGB) RGB {
	println('modifying pixel')
	dump(pixel)
	pixel.r = 2
	dump(pixel)
	return pixel
}

// Wapper function
fn pixfn2(mut pixel PixelRepresenation) PixelRepresenation {
	dump(pixel)

	// 'match' works for type casting
	match mut pixel {
		RGB {
			pixel = &PixelRepresenation(pixfn1(mut pixel))
		}
		// RGBf64 { /* ... */ }
		else {
			println('no match')
		}
	}
	return pixel
}

// Wapper function
fn rgb_fn_wrapper(func fn (mut RGB) RGB) PixelEditFn {
	my_closure := fn [func] (mut pixel PixelRepresenation) PixelRepresenation {
		match mut pixel {
			RGB {
				pixel = &PixelRepresenation(func(mut pixel))
			}
			// RGBf64 { /* ... */ }
			else {
				println('no match')
			}
		}
		return pixel
	}
	return my_closure
}

fn main() {
	mut pix := RGB{
		r: 1
		g: 2
		b: 3
	}

	mut pipeline := PixelEditPipeline{
		steps: []PixelEditStep{}
	}

	step := PixelEditStep{
		// func: unsafe {PixelEditFn(pixfn1)} // this works but reference gets lost somewhere
		// func: pixfn1 // errors because of type mismatch
		// func: pixfn2 // warpper with type casting
		func: rgb_fn_wrapper(pixfn1)
	}
	pipeline.addstep(step)
	newpix := pipeline.exec(mut pix)

	println(newpix)

	// println(PixelRepresenation(pix))
	// println((PixelRepresenation(pix) as RGB).r)
	// println(typeof(pixfn1))
	// println(typeof(pixfn1))
	// println(typeof(pixfn1).name)
	// println(typeof(pix).name)

	// println((ref.type_of(oklab.gamut_clip_project_to_0_5).sym.info as ref.Function).return_typ)
	// println(ref.type_of(oklab.gamut_clip_project_to_0_5).sym.info)
	// println(ref.type_of(oklab.gamut_clip_project_to_0_5))
}
