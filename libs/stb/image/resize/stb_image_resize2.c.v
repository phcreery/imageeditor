module resize

// #flag -I @VMODROOT/thirdparty/stb
// #define STB_IMAGE_RESIZE_IMPLEMENTATION
// #include "stb_image_resize2.h"

// normally we would define and include like above,
// but vlang's std lib already includes stb_image_resize2.h
// so we are just going to make a faithful wrapper around the api

// stb_image_resize2 - v2.12 - public domain image resizing
//
//   by Jeff Roberts (v2) and Jorge L Rodriguez
//   http://github.com/nothings/stb
//
//   Can be threaded with the extended API. SSE2, AVX, Neon and WASM SIMD support. Only
//   scaling and translation is supported, no rotations or shears.
//
//   COMPILING & LINKING
//      In one C/C++ file that #includes this file, do this:
//         #define STB_IMAGE_RESIZE_IMPLEMENTATION
//      before the #include. That will create the implementation in that file.
//
//   EASY API CALLS:
//     Easy API downsamples w/Mitchell filter, upsamples w/cubic interpolation, clamps to edge.
//
//     stbir_resize_uint8_srgb( input_pixels,  input_w,  input_h,  input_stride_in_bytes,
//                              output_pixels, output_w, output_h, output_stride_in_bytes,
//                              pixel_layout_enum )
//
//     stbir_resize_uint8_linear( input_pixels,  input_w,  input_h,  input_stride_in_bytes,
//                                output_pixels, output_w, output_h, output_stride_in_bytes,
//                                pixel_layout_enum )
//
//     stbir_resize_float_linear( input_pixels,  input_w,  input_h,  input_stride_in_bytes,
//                                output_pixels, output_w, output_h, output_stride_in_bytes,
//                                pixel_layout_enum )
//
//     If you pass NULL or zero for the output_pixels, we will allocate the output buffer
//     for you and return it from the function (free with free() or STBIR_FREE).
//     As a special case, XX_stride_in_bytes of 0 means packed continuously in memory.
//
//   API LEVELS
//      There are three levels of API - easy-to-use, medium-complexity and extended-complexity.
//
//      See the "header file" section of the source for API documentation.
//
//   ADDITIONAL DOCUMENTATION
//
//      MEMORY ALLOCATION
//         By default, we use malloc and free for memory allocation.  To override the
//         memory allocation, before the implementation #include, add a:
//
//            #define STBIR_MALLOC(size,user_data) ...
//            #define STBIR_FREE(ptr,user_data)   ...
//
//         Each resize makes exactly one call to malloc/free (unless you use the
//         extended API where you can do one allocation for many resizes). Under
//         address sanitizer, we do separate allocations to find overread/writes.
//
//      PERFORMANCE
//         This library was written with an emphasis on performance. When testing
//         stb_image_resize with RGBA, the fastest mode is STBIR_4CHANNEL with
//         STBIR_TYPE_UINT8 pixels and CLAMPed edges (which is what many other resize
//         libs do by default). Also, make sure SIMD is turned on of course (default
//         for 64-bit targets). Avoid WRAP edge mode if you want the fastest speed.
//
//         This library also comes with profiling built-in. If you define STBIR_PROFILE,
//         you can use the advanced API and get low-level profiling information by
//         calling stbir_resize_extended_profile_info() or stbir_resize_split_profile_info()
//         after a resize.
//
//      SIMD
//         Most of the routines have optimized SSE2, AVX, NEON and WASM versions.
//
//         On Microsoft compilers, we automatically turn on SIMD for 64-bit x64 and
//         ARM; for 32-bit x86 and ARM, you select SIMD mode by defining STBIR_SSE2 or
//         STBIR_NEON. For AVX and AVX2, we auto-select it by detecting the /arch:AVX
//         or /arch:AVX2 switches. You can also always manually turn SSE2, AVX or AVX2
//         support on by defining STBIR_SSE2, STBIR_AVX or STBIR_AVX2.
//
//         On Linux, SSE2 and Neon is on by default for 64-bit x64 or ARM64. For 32-bit,
//         we select x86 SIMD mode by whether you have -msse2, -mavx or -mavx2 enabled
//         on the command line. For 32-bit ARM, you must pass -mfpu=neon-vfpv4 for both
//         clang and GCC, but GCC also requires an additional -mfp16-format=ieee to
//         automatically enable NEON.
//
//         On x86 platforms, you can also define STBIR_FP16C to turn on FP16C instructions
//         for converting back and forth to half-floats. This is autoselected when we
//         are using AVX2. Clang and GCC also require the -mf16c switch. ARM always uses
//         the built-in half float hardware NEON instructions.
//
//         You can also tell us to use multiply-add instructions with STBIR_USE_FMA.
//         Because x86 doesn't always have fma, we turn it off by default to maintain
//         determinism across all platforms. If you don't care about non-FMA determinism
//         and are willing to restrict yourself to more recent x86 CPUs (around the AVX
//         timeframe), then fma will give you around a 15% speedup.
//
//         You can force off SIMD in all cases by defining STBIR_NO_SIMD. You can turn
//         off AVX or AVX2 specifically with STBIR_NO_AVX or STBIR_NO_AVX2. AVX is 10%
//         to 40% faster, and AVX2 is generally another 12%.
//
//      ALPHA CHANNEL
//         Most of the resizing functions provide the ability to control how the alpha
//         channel of an image is processed.
//
//         When alpha represents transparency, it is important that when combining
//         colors with filtering, the pixels should not be treated equally; they
//         should use a weighted average based on their alpha values. For example,
//         if a pixel is 1% opaque bright green and another pixel is 99% opaque
//         black and you average them, the average will be 50% opaque, but the
//         unweighted average and will be a middling green color, while the weighted
//         average will be nearly black. This means the unweighted version introduced
//         green energy that didn't exist in the source image.
//
//         (If you want to know why this makes sense, you can work out the math for
//         the following: consider what happens if you alpha composite a source image
//         over a fixed color and then average the output, vs. if you average the
//         source image pixels and then composite that over the same fixed color.
//         Only the weighted average produces the same result as the ground truth
//         composite-then-average result.)
//
//         Therefore, it is in general best to "alpha weight" the pixels when applying
//         filters to them. This essentially means multiplying the colors by the alpha
//         values before combining them, and then dividing by the alpha value at the
//         end.
//
//         The computer graphics industry introduced a technique called "premultiplied
//         alpha" or "associated alpha" in which image colors are stored in image files
//         already multiplied by their alpha. This saves some math when compositing,
//         and also avoids the need to divide by the alpha at the end (which is quite
//         inefficient). However, while premultiplied alpha is common in the movie CGI
//         industry, it is not commonplace in other industries like videogames, and most
//         consumer file formats are generally expected to contain not-premultiplied
//         colors. For example, Photoshop saves PNG files "unpremultiplied", and web
//         browsers like Chrome and Firefox expect PNG images to be unpremultiplied.
//
//         Note that there are three possibilities that might describe your image
//         and resize expectation:
//
//             1. images are not premultiplied, alpha weighting is desired
//             2. images are not premultiplied, alpha weighting is not desired
//             3. images are premultiplied
//
//         Both case #2 and case #3 require the exact same math: no alpha weighting
//         should be applied or removed. Only case 1 requires extra math operations;
//         the other two cases can be handled identically.
//
//         stb_image_resize expects case #1 by default, applying alpha weighting to
//         images, expecting the input images to be unpremultiplied. This is what the
//         COLOR+ALPHA buffer types tell the resizer to do.
//
//         When you use the pixel layouts STBIR_RGBA, STBIR_BGRA, STBIR_ARGB,
//         STBIR_ABGR, STBIR_RX, or STBIR_XR you are telling us that the pixels are
//         non-premultiplied. In these cases, the resizer will alpha weight the colors
//         (effectively creating the premultiplied image), do the filtering, and then
//         convert back to non-premult on exit.
//
//         When you use the pixel layouts STBIR_RGBA_PM, STBIR_RGBA_PM, STBIR_RGBA_PM,
//         STBIR_RGBA_PM, STBIR_RX_PM or STBIR_XR_PM, you are telling that the pixels
//         ARE premultiplied. In this case, the resizer doesn't have to do the
//         premultipling - it can filter directly on the input. This about twice as
//         fast as the non-premultiplied case, so it's the right option if your data is
//         already setup correctly.
//
//         When you use the pixel layout STBIR_4CHANNEL or STBIR_2CHANNEL, you are
//         telling us that there is no channel that represents transparency; it may be
//         RGB and some unrelated fourth channel that has been stored in the alpha
//         channel, but it is actually not alpha. No special processing will be
//         performed.
//
//         The difference between the generic 4 or 2 channel layouts, and the
//         specialized _PM versions is with the _PM versions you are telling us that
//         the data *s*alpha, just don't premultiply it. That's important when
//         using SRGB pixel formats, we need to know where the alpha is, because
//         it is converted linearly (rather than with the SRGB converters).
//
//         Because alpha weighting produces the same effect as premultiplying, you
//         even have the option with non-premultiplied inputs to let the resizer
//         produce a premultiplied output. Because the intially computed alpha-weighted
//         output image is effectively premultiplied, this is actually more performant
//         than the normal path which un-premultiplies the output image as a final step.
//
//         Finally, when converting both in and out of non-premulitplied space (for
//         example, when using STBIR_RGBA), we go to somewhat heroic measures to
//         ensure that areas with zero alpha value pixels get something reasonable
//         in the RGB values. If you don't care about the RGB values of zero alpha
//         pixels, you can call the stbir_set_non_pm_alpha_speed_over_quality()
//         function - this runs a premultiplied resize about 25% faster. That said,
//         when you really care about speed, using premultiplied pixels for both in
//         and out (STBIR_RGBA_PM, etc) much faster than both of these premultiplied
//         options.
//
//      PIXEL LAYOUT CONVERSION
//         The resizer can convert from some pixel layouts to others. When using the
//         stbir_set_pixel_layouts(), you can, for example, specify STBIR_RGBA
//         on input, and STBIR_ARGB on output, and it will re-organize the channels
//         during the resize. Currently, you can only convert between two pixel
//         layouts with the same number of channels.
//
//      DETERMINISM
//         We commit to being deterministic (from x64 to ARM to scalar to SIMD, etc).
//         This requires compiling with fast-math off (using at least /fp:precise).
//         Also, you must turn off fp-contracting (which turns mult+adds into fmas)!
//         We attempt to do this with pragmas, but with Clang, you usually want to add
//         -ffp-contract=off to the command line as well.
//
//         For 32-bit x86, you must use SSE and SSE2 codegen for determinism. That is,
//         if the scalar x87 unit gets used at all, we immediately lose determinism.
//         On Microsoft Visual Studio 2008 and earlier, from what we can tell there is
//         no way to be deterministic in 32-bit x86 (some x87 always leaks in, even
//         with fp:strict). On 32-bit x86 GCC, determinism requires both -msse2 and
//         -fpmath=sse.
//
//         Note that we will not be deterministic with float data containing NaNs -
//         the NaNs will propagate differently on different SIMD and platforms.
//
//         If you turn on STBIR_USE_FMA, then we will be deterministic with other
//         fma targets, but we will differ from non-fma targets (this is unavoidable,
//         because a fma isn't simply an add with a mult - it also introduces a
//         rounding difference compared to non-fma instruction sequences.
//
//      FLOAT PIXEL FORMAT RANGE
//         Any range of values can be used for the non-alpha float data that you pass
//         in (0 to 1, -1 to 1, whatever). However, if you are inputting float values
//         but *utputting*bytes or shorts, you must use a range of 0 to 1 so that we
//         scale back properly. The alpha channel must also be 0 to 1 for any format
//         that does premultiplication prior to resizing.
//
//         Note also that with float output, using filters with negative lobes, the
//         output filtered values might go slightly out of range. You can define
//         STBIR_FLOAT_LOW_CLAMP and/or STBIR_FLOAT_HIGH_CLAMP to specify the range
//         to clamp to on output, if that's important.
//
//      MAX/MIN SCALE FACTORS
//         The input pixel resolutions are in integers, and we do the internal pointer
//         resolution in size_t sized integers. However, the scale ratio from input
//         resolution to output resolution is calculated in float form. This means
//         the effective possible scale ratio is limited to 24 bits (or 16 million
//         to 1). As you get close to the size of the float resolution (again, 16
//         million pixels wide or high), you might start seeing float inaccuracy
//         issues in general in the pipeline. If you have to do extreme resizes,
//         you can usually do this is multiple stages (using float intermediate
//         buffers).
//
//      FLIPPED IMAGES
//         Stride is just the delta from one scanline to the next. This means you can
//         use a negative stride to handle inverted images (point to the final
//         scanline and use a negative stride). You can invert the input or output,
//         using negative strides.
//
//      DEFAULT FILTERS
//         For functions which don't provide explicit control over what filters to
//         use, you can change the compile-time defaults with:
//
//            #define STBIR_DEFAULT_FILTER_UPSAMPLE     STBIR_FILTER_something
//            #define STBIR_DEFAULT_FILTER_DOWNSAMPLE   STBIR_FILTER_something
//
//         See stbir_filter in the header-file section for the list of filters.
//
//      NEW FILTERS
//         A number of 1D filter kernels are supplied. For a list of supported
//         filters, see the stbir_filter enum. You can install your own filters by
//         using the stbir_set_filter_callbacks function.
//
//      PROGRESS
//         For interactive use with slow resize operations, you can use the the
//         scanline callbacks in the extended API. It would have to be a *ery*large
//         image resample to need progress though - we're very fast.
//
//      CEIL and FLOOR
//         In scalar mode, the only functions we use from math.h are ceilf and floorf,
//         but if you have your own versions, you can define the STBIR_CEILF(v) and
//         STBIR_FLOORF(v) macros and we'll use them instead. In SIMD, we just use
//         our own versions.
//
//      ASSERT
//         Define STBIR_ASSERT(boolval) to override assert() and not use assert.h
//
//     PORTING FROM VERSION 1
//        The API has changed. You can continue to use the old version of stb_image_resize.h,
//        which is available in the "deprecated/" directory.
//
//        If you're using the old simple-to-use API, porting is straightforward.
//        (For more advanced APIs, read the documentation.)
//
//          stbir_resize_uint8():
//            - call `stbir_resize_uint8_linear`, cast channel count to `stbir_pixel_layout`
//
//          stbir_resize_float():
//            - call `stbir_resize_float_linear`, cast channel count to `stbir_pixel_layout`
//
//          stbir_resize_uint8_srgb():
//            - function name is unchanged
//            - cast channel count to `stbir_pixel_layout`
//            - above is sufficient unless your image has alpha and it's not RGBA/BGRA
//              - in that case, follow the below instructions for stbir_resize_uint8_srgb_edgemode
//
//          stbir_resize_uint8_srgb_edgemode()
//            - switch to the "medium complexity" API
//            - stbir_resize(), very similar API but a few more parameters:
//              - pixel_layout: cast channel count to `stbir_pixel_layout`
//              - data_type:    STBIR_TYPE_UINT8_SRGB
//              - edge:         unchanged (STBIR_EDGE_WRAP, etc.)
//              - filter:       STBIR_FILTER_DEFAULT
//            - which channel is alpha is specified in stbir_pixel_layout, see enum for details
//
//      FUTURE TODOS
//        * For polyphase integral filters, we just memcpy the coeffs to dupe
//           them, but we should indirect and use the same coeff memory.
//        * Add pixel layout conversions for sensible different channel counts
//           (maybe, 1->3/4, 3->4, 4->1, 3->1).
//         *For SIMD encode and decode scanline routines, do any pre-aligning
//           for bad input/output buffer alignments and pitch?
//         *For very wide scanlines, we should we do vertical strips to stay within
//           L2 cache. Maybe do chunks of 1K pixels at a time. There would be
//           some pixel reconversion, but probably dwarfed by things falling out
//           of cache. Probably also something possible with alternating between
//           scattering and gathering at high resize scales?
//         *Rewrite the coefficient generator to do many at once.
//         *AVX-512 vertical kernels - worried about downclocking here.
//         *Convert the reincludes to macros when we know they aren't changing.
//         *Experiment with pivoting the horizontal and always using the
//           vertical filters (which are faster, but perhaps not enough to overcome
//           the pivot cost and the extra memory touches). Need to buffer the whole
//           image so have to balance memory use.
//         *Most of our code is internally function pointers, should we compile
//           all the SIMD stuff always and dynamically dispatch?
//
//   CONTRIBUTORS
//      Jeff Roberts: 2.0 implementation, optimizations, SIMD
//      Martins Mozeiko: NEON simd, WASM simd, clang and GCC whisperer
//      Fabian Giesen: half float and srgb converters
//      Sean Barrett: API design, optimizations
//      Jorge L Rodriguez: Original 1.0 implementation
//      Aras Pranckevicius: bugfixes
//      Nathan Reed: warning fixes for 1.0
//
//   REVISIONS
//      2.12 (2024-10-18) fix incorrect use of user_data with STBIR_FREE
//      2.11 (2024-09-08) fix harmless asan warnings in 2-channel and 3-channel mode
//                          with AVX-2, fix some weird scaling edge conditions with
//                          point sample mode.
//      2.10 (2024-07-27) fix the defines GCC and mingw for loop unroll control,
//                          fix MSVC 32-bit arm half float routines.
//      2.09 (2024-06-19) fix the defines for 32-bit ARM GCC builds (was selecting
//                          hardware half floats).
//      2.08 (2024-06-10) fix for RGB->BGR three channel flips and add SIMD (thanks
//                          to Ryan Salsbury), fix for sub-rect resizes, use the
//                          pragmas to control unrolling when they are available.
//      2.07 (2024-05-24) fix for slow final split during threaded conversions of very
//                          wide scanlines when downsampling (caused by extra input
//                          converting), fix for wide scanline resamples with many
//                          splits (int overflow), fix GCC warning.
//      2.06 (2024-02-10) fix for identical width/height 3x or more down-scaling
//                          undersampling a single row on rare resize ratios (about 1%).
//      2.05 (2024-02-07) fix for 2 pixel to 1 pixel resizes with wrap (thanks Aras),
//                        fix for output callback (thanks Julien Koenen).
//      2.04 (2023-11-17) fix for rare AVX bug, shadowed symbol (thanks Nikola Smiljanic).
//      2.03 (2023-11-01) ASAN and TSAN warnings fixed, minor tweaks.
//      2.00 (2023-10-10) mostly new source: new api, optimizations, simd, vertical-first, etc
//                          2x-5x faster without simd, 4x-12x faster with simd,
//                          in some cases, 20x to 40x faster esp resizing large to very small.
//      0.96 (2019-03-04) fixed warnings
//      0.95 (2017-07-23) fixed warnings
//      0.94 (2017-03-18) fixed warnings
//      0.93 (2017-03-03) fixed bug with certain combinations of heights
//      0.92 (2017-01-02) fix integer overflow on large (>2GB) images
//      0.91 (2016-04-02) fix warnings; fix handling of subpixel regions
//      0.90 (2014-09-17) first released version
//
//   LICENSE
//     See end of file for license information.
//
// for internal re-includes
type Stbir_uint8 = u8
type Stbir_uint16 = u16
type Stbir_uint32 = u32
type Stbir_uint64 = i64

// FP16C instructions are on all AVX2 cpus, so we can autoselect it here on microsoft - clang needs -m16c
// turn on FP16C instructions if the define is set (for clang and gcc)
// no FMA for 32-bit arm on MSVC
//////////////////////////////////////////////////////////////////////////////
////   start "header file" ///////////////////////////////////////////////////
//
// Easy-to-use API:
//
//     * stride is the offset between successive rows of image data
//        in memory, in bytes. specify 0 for packed continuously in memory
//     * colorspace is linear or sRGB as specified by function name
//     * Uses the default filters
//     * Uses edge mode clamped
//     * returned result is 1 for success or 0 in case of an error.
// stbir_pixel_layout specifies:
//   number of channels
//   order of channels
//   whether color is premultiplied by alpha
// for back compatibility, you can cast the old channel count to an stbir_pixel_layout
pub enum Stbir_pixel_layout {
	stbir_1_channel = 1
	stbir_2_channel = 2
	stbir_rgb       = 3

	// 3-chan, with order specified (for channel flipping)
	stbir_bgr = 0

	// 3-chan, with order specified (for channel flipping)
	stbir_4_channel = 5
	stbir_rgba      = 4

	// alpha formats, where alpha is NOT premultiplied into color channels
	stbir_bgra    = 6
	stbir_argb    = 7
	stbir_abgr    = 8
	stbir_ra      = 9
	stbir_ar      = 10
	stbir_rgba_pm = 11

	// alpha formats, where alpha is premultiplied into color channels
	stbir_bgra_pm = 12
	stbir_argb_pm = 13
	stbir_abgr_pm = 14
	stbir_ra_pm   = 15
	stbir_ar_pm   = 16
}

// stbir_rgba_no_aw = 11
// alpha formats, where NO alpha weighting is applied at all!
// stbir_bgra_no_aw = 12
//   these are just synonyms for the _PM flags (which also do
// stbir_argb_no_aw = 13
//   no alpha weighting). These names just make it more clear
// stbir_abgr_no_aw = 14
//   for some folks).
// stbir_ra_no_aw = 15
// stbir_ar_no_aw = 16

//===============================================================
//  Simple-complexity API
//
//    If output_pixels is NULL (0), then we will allocate the buffer and return it to you.
//--------------------------------
fn C.stbir_resize_uint8_srgb(input_pixels &u8, input_w int, input_h int, input_stride_in_bytes int, output_pixels &u8, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &u8

pub fn stbir_resize_uint8_srgb(input_pixels &u8, input_w int, input_h int, input_stride_in_bytes int, output_pixels &u8, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &u8 {
	return C.stbir_resize_uint8_srgb(input_pixels, input_w, input_h, input_stride_in_bytes,
		output_pixels, output_w, output_h, output_stride_in_bytes, pixel_type)
}

// fn C.stbir_resize_uint8_linear(input_pixels &u8, input_w int, input_h int, input_stride_in_bytes int, output_pixels &u8, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &u8

// This is already defined in stbi std lib
pub fn stbir_resize_uint8_linear(input_pixels &u8, input_w int, input_h int, input_stride_in_bytes int, output_pixels &u8, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &u8 {
	// return C.stbir_resize_uint8_linear(input_pixels, input_w, input_h, input_stride_in_bytes,
	// 	output_pixels, output_w, output_h, output_stride_in_bytes, pixel_type)
	return &u8(C.stbir_resize_uint8_linear(input_pixels, input_w, input_h, input_stride_in_bytes,
		output_pixels, output_w, output_h, output_stride_in_bytes, int(pixel_type)))
}

fn C.stbir_resize_float_linear(input_pixels &f32, input_w int, input_h int, input_stride_in_bytes int, output_pixels &f32, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &f32

pub fn stbir_resize_float_linear(input_pixels &f32, input_w int, input_h int, input_stride_in_bytes int, output_pixels &f32, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &f32 {
	return C.stbir_resize_float_linear(input_pixels, input_w, input_h, input_stride_in_bytes,
		output_pixels, output_w, output_h, output_stride_in_bytes, pixel_type)
}

//===============================================================
//===============================================================
// Medium-complexity API
//
// This extends the easy-to-use API as follows:
//
//     * Can specify the datatype - U8, U8_SRGB, U16, FLOAT, HALF_FLOAT
//     * Edge wrap can selected explicitly
//     * Filter can be selected explicitly
//--------------------------------
pub enum Stbir_edge {
	stbir_edge_clamp   = 0
	stbir_edge_reflect = 1
	stbir_edge_wrap    = 2

	// this edge mode is slower and uses more memory
	stbir_edge_zero = 3
}

pub enum Stbir_filter {
	stbir_filter_default = 0

	// use same filter type that easy-to-use API chooses
	stbir_filter_box = 1

	// A trapezoid w/1-pixel wide ramps, same result as box for integer scale ratios
	stbir_filter_triangle = 2

	// On upsampling, produces same results as bilinear texture filtering
	stbir_filter_cubicbspline = 3

	// The cubic b-spline (aka Mitchell-Netrevalli with B=1,C=0), gaussian-esque
	stbir_filter_catmullrom = 4

	// An interpolating cubic spline
	stbir_filter_mitchell = 5

	// Mitchell-Netrevalli filter with B=1/3, C=1/3
	stbir_filter_point_sample = 6

	// Simple point sampling
	stbir_filter_other = 7
}

// User callback specified
enum Stbir_datatype {
	stbir_type_uint_8            = 0
	stbir_type_uint_8_srgb       = 1
	stbir_type_uint_8_srgb_alpha = 2

	// alpha channel, when present, should also be SRGB (this is very unusual)
	stbir_type_uint_16    = 3
	stbir_type_float      = 4
	stbir_type_half_float = 5
}

// medium api
fn C.stbir_resize(input_pixels voidptr, input_w int, input_h int, input_stride_in_bytes int, output_pixels voidptr, output_w int, output_h int, output_stride_in_bytes int, pixel_layout Stbir_pixel_layout, data_type Stbir_datatype, edge Stbir_edge, filter Stbir_filter) voidptr

pub fn stbir_resize(input_pixels voidptr, input_w int, input_h int, input_stride_in_bytes int, output_pixels voidptr, output_w int, output_h int, output_stride_in_bytes int, pixel_layout Stbir_pixel_layout, data_type Stbir_datatype, edge Stbir_edge, filter Stbir_filter) voidptr {
	return C.stbir_resize(input_pixels, input_w, input_h, input_stride_in_bytes, output_pixels,
		output_w, output_h, output_stride_in_bytes, pixel_layout, data_type, edge, filter)
}

//===============================================================
//===============================================================
// Extended-complexity API
//
// This API exposes all resize functionality.
//
//     * Separate filter types for each axis
//     * Separate edge modes for each axis
//     * Separate input and output data types
//     * Can specify regions with subpixel correctness
//     * Can specify alpha flags
//     * Can specify a memory callback
//     * Can specify a callback data type for pixel input and output
//     * Can be threaded for a single resize
//     * Can be used to resize many frames without recalculating the sampler info
//
//  Use this API as follows:
//     1) Call the stbir_resize_init function on a local STBIR_RESIZE structure
//     2) Call any of the stbir_set functions
//     3) Optionally call stbir_build_samplers() if you are going to resample multiple times
//        with the same input and output dimensions (like resizing video frames)
//     4) Resample by calling stbir_resize_extended().
//     5) Call stbir_free_samplers() if you called stbir_build_samplers()
//--------------------------------
// Types:
// INPUT CALLBACK: this callback is used for input scanlines
// type Stbir_input_callback = Void *(void *,voidptr, int, int, int,voidptr)
// typedef void const * stbir_input_callback( void * optional_output, void const * input_ptr, int num_pixels, int x, int y, void * context );
type Stbir_input_callback = fn (optional_output voidptr, input_ptr voidptr, num_pixels int, x int, y int, context voidptr)

// OUTPUT CALLBACK: this callback is used for output scanlines
// type Stbir_output_callback = Void (void *, int, int,voidptr)
// typedef void stbir_output_callback( void const * output_ptr, int num_pixels, int y, void * context );
type Stbir_output_callback = fn (output_ptr voidptr, num_pixels int, y int, context voidptr)

// callbacks for user installed filters
// type Stbir__kernel_callback = Float (float, float,voidptr)
// typedef float stbir__kernel_callback( float x, float scale, void * user_data ); // centered at zero
type Stbir__kernel_callback = fn (x f32, scale f32, user_data voidptr)

// centered at zero
// type Stbir__support_callback = Float (float,voidptr)
// typedef float stbir__support_callback( float scale, void * user_data );
type Stbir__support_callback = fn (scale f32, user_data voidptr)

// internal structure with precomputed scaling
struct STBIR_RESIZE {
	// use the stbir_resize_init and stbir_override functions to set these values for future compatibility
	user_data                  voidptr
	input_pixels               voidptr
	input_w                    int
	input_h                    int
	input_s0                   f64
	input_t0                   f64
	input_s1                   f64
	input_t1                   f64
	input_cb                   &Stbir_input_callback
	output_pixels              voidptr
	output_w                   int
	output_h                   int
	output_subx                int
	output_suby                int
	output_subw                int
	output_subh                int
	output_cb                  &Stbir_output_callback
	input_stride_in_bytes      int
	output_stride_in_bytes     int
	splits                     int
	fast_alpha                 int
	needs_rebuild              int
	called_alloc               int
	input_pixel_layout_public  Stbir_pixel_layout
	output_pixel_layout_public Stbir_pixel_layout
	input_data_type            Stbir_datatype
	output_data_type           Stbir_datatype
	horizontal_filter          Stbir_filter
	vertical_filter            Stbir_filter
	horizontal_edge            Stbir_edge
	vertical_edge              Stbir_edge
	horizontal_filter_kernel   &Stbir__kernel_callback
	horizontal_filter_support  &Stbir__support_callback
	vertical_filter_kernel     &Stbir__kernel_callback
	vertical_filter_support    &Stbir__support_callback
}

// samplers &Stbir__info
// extended complexity api
// First off, you must ALWAYS call stbir_resize_init on your resize structure before any of the other calls!
fn C.stbir_resize_init(resize &STBIR_RESIZE, input_pixels voidptr, input_w int, input_h int, input_stride_in_bytes int, output_pixels voidptr, output_w int, output_h int, output_stride_in_bytes int, pixel_layout Stbir_pixel_layout, data_type Stbir_datatype)

pub fn stbir_resize_init(resize &STBIR_RESIZE, input_pixels voidptr, input_w int, input_h int, input_stride_in_bytes int, output_pixels voidptr, output_w int, output_h int, output_stride_in_bytes int, pixel_layout Stbir_pixel_layout, data_type Stbir_datatype) {
	C.stbir_resize_init(resize, input_pixels, input_w, input_h, input_stride_in_bytes,
		output_pixels, output_w, output_h, output_stride_in_bytes, pixel_layout, data_type)
}

//===============================================================
// You can update these parameters any time after resize_init and there is no cost
//--------------------------------
fn C.stbir_set_datatypes(resize &STBIR_RESIZE, input_type Stbir_datatype, output_type Stbir_datatype)

pub fn stbir_set_datatypes(resize &STBIR_RESIZE, input_type Stbir_datatype, output_type Stbir_datatype) {
	C.stbir_set_datatypes(resize, input_type, output_type)
}

fn C.stbir_set_pixel_callbacks(resize &STBIR_RESIZE, input_cb &Stbir_input_callback, output_cb &Stbir_output_callback)

pub fn stbir_set_pixel_callbacks(resize &STBIR_RESIZE, input_cb &Stbir_input_callback, output_cb &Stbir_output_callback) {
	C.stbir_set_pixel_callbacks(resize, input_cb, output_cb)
}

// no callbacks by default
fn C.stbir_set_user_data(resize &STBIR_RESIZE, user_data voidptr)

pub fn stbir_set_user_data(resize &STBIR_RESIZE, user_data voidptr) {
	C.stbir_set_user_data(resize, user_data)
}

// pass back STBIR_RESIZE* by default
fn C.stbir_set_buffer_ptrs(resize &STBIR_RESIZE, input_pixels voidptr, input_stride_in_bytes int, output_pixels voidptr, output_stride_in_bytes int)

pub fn stbir_set_buffer_ptrs(resize &STBIR_RESIZE, input_pixels voidptr, input_stride_in_bytes int, output_pixels voidptr, output_stride_in_bytes int) {
	C.stbir_set_buffer_ptrs(resize, input_pixels, input_stride_in_bytes, output_pixels,
		output_stride_in_bytes)
}

//===============================================================
//===============================================================
// If you call any of these functions, you will trigger a sampler rebuild!
//--------------------------------
fn C.stbir_set_pixel_layouts(resize &STBIR_RESIZE, input_pixel_layout Stbir_pixel_layout, output_pixel_layout Stbir_pixel_layout) int

pub fn stbir_set_pixel_layouts(resize &STBIR_RESIZE, input_pixel_layout Stbir_pixel_layout, output_pixel_layout Stbir_pixel_layout) int {
	return C.stbir_set_pixel_layouts(resize, input_pixel_layout, output_pixel_layout)
}

// sets new buffer layouts
fn C.stbir_set_edgemodes(resize &STBIR_RESIZE, horizontal_edge Stbir_edge, vertical_edge Stbir_edge) int

pub fn stbir_set_edgemodes(resize &STBIR_RESIZE, horizontal_edge Stbir_edge, vertical_edge Stbir_edge) int {
	return C.stbir_set_edgemodes(resize, horizontal_edge, vertical_edge)
}

// CLAMP by default
fn C.stbir_set_filters(resize &STBIR_RESIZE, horizontal_filter Stbir_filter, vertical_filter Stbir_filter) int

pub fn stbir_set_filters(resize &STBIR_RESIZE, horizontal_filter Stbir_filter, vertical_filter Stbir_filter) int {
	return C.stbir_set_filters(resize, horizontal_filter, vertical_filter)
}

// STBIR_DEFAULT_FILTER_UPSAMPLE/DOWNSAMPLE by default
fn C.stbir_set_filter_callbacks(resize &STBIR_RESIZE, horizontal_filter &Stbir__kernel_callback, horizontal_support &Stbir__support_callback, vertical_filter &Stbir__kernel_callback, vertical_support &Stbir__support_callback) int

pub fn stbir_set_filter_callbacks(resize &STBIR_RESIZE, horizontal_filter &Stbir__kernel_callback, horizontal_support &Stbir__support_callback, vertical_filter &Stbir__kernel_callback, vertical_support &Stbir__support_callback) int {
	return C.stbir_set_filter_callbacks(resize, horizontal_filter, horizontal_support,
		vertical_filter, vertical_support)
}

fn C.stbir_set_pixel_subrect(resize &STBIR_RESIZE, subx int, suby int, subw int, subh int) int

pub fn stbir_set_pixel_subrect(resize &STBIR_RESIZE, subx int, suby int, subw int, subh int) int {
	return C.stbir_set_pixel_subrect(resize, subx, suby, subw, subh)
}

// sets both sub-regions (full regions by default)
fn C.stbir_set_input_subrect(resize &STBIR_RESIZE, s0 f64, t0 f64, s1 f64, t1 f64) int

pub fn stbir_set_input_subrect(resize &STBIR_RESIZE, s0 f64, t0 f64, s1 f64, t1 f64) int {
	return C.stbir_set_input_subrect(resize, s0, t0, s1, t1)
}

// sets input sub-region (full region by default)
fn C.stbir_set_output_pixel_subrect(resize &STBIR_RESIZE, subx int, suby int, subw int, subh int) int

pub fn stbir_set_output_pixel_subrect(resize &STBIR_RESIZE, subx int, suby int, subw int, subh int) int {
	return C.stbir_set_output_pixel_subrect(resize, subx, suby, subw, subh)
}

// sets output sub-region (full region by default)
// when inputting AND outputting non-premultiplied alpha pixels, we use a slower but higher quality technique
//   that fills the zero alpha pixel's RGB values with something plausible.  If you don't care about areas of
//   zero alpha, you can call this function to get about a 25% speed improvement for STBIR_RGBA to STBIR_RGBA
//   types of resizes.
fn C.stbir_set_non_pm_alpha_speed_over_quality(resize &STBIR_RESIZE, non_pma_alpha_speed_over_quality int) int

pub fn stbir_set_non_pm_alpha_speed_over_quality(resize &STBIR_RESIZE, non_pma_alpha_speed_over_quality int) int {
	return C.stbir_set_non_pm_alpha_speed_over_quality(resize, non_pma_alpha_speed_over_quality)
}

//===============================================================
//===============================================================
// You can call build_samplers to prebuild all the internal data we need to resample.
//   Then, if you call resize_extended many times with the same resize, you only pay the
//   cost once.
// If you do call build_samplers, you MUST call free_samplers eventually.
//--------------------------------
// This builds the samplers and does one allocation
fn C.stbir_build_samplers(resize &STBIR_RESIZE) int

pub fn stbir_build_samplers(resize &STBIR_RESIZE) int {
	return C.stbir_build_samplers(resize)
}

// You MUST call this, if you call stbir_build_samplers or stbir_build_samplers_with_splits
fn C.stbir_free_samplers(resize &STBIR_RESIZE)

pub fn stbir_free_samplers(resize &STBIR_RESIZE) {
	C.stbir_free_samplers(resize)
}

//===============================================================
// And this is the main function to perform the resize synchronously on one thread.
fn C.stbir_resize_extended(resize &STBIR_RESIZE) int

pub fn stbir_resize_extended(resize &STBIR_RESIZE) int {
	return C.stbir_resize_extended(resize)
}

//===============================================================
// Use these functions for multithreading.
//   1) You call stbir_build_samplers_with_splits first on the main thread
//   2) Then stbir_resize_with_split on each thread
//   3) stbir_free_samplers when done on the main thread
//--------------------------------
// This will build samplers for threading.
//   You can pass in the number of threads you'd like to use (try_splits).
//   It returns the number of splits (threads) that you can call it with.
///  It might be less if the image resize can't be split up that many ways.
fn C.stbir_build_samplers_with_splits(resize &STBIR_RESIZE, try_splits int) int

pub fn stbir_build_samplers_with_splits(resize &STBIR_RESIZE, try_splits int) int {
	return C.stbir_build_samplers_with_splits(resize, try_splits)
}

// This function does a split of the resizing (you call this fuction for each
// split, on multiple threads). A split is a piece of the output resize pixel space.
// Note that you MUST call stbir_build_samplers_with_splits before stbir_resize_extended_split!
// Usually, you will always call stbir_resize_split with split_start as the thread_index
//   and "1" for the split_count.
// But, if you have a weird situation where you MIGHT want 8 threads, but sometimes
//   only 4 threads, you can use 0,2,4,6 for the split_start's and use "2" for the
//   split_count each time to turn in into a 4 thread resize. (This is unusual).
fn C.stbir_resize_extended_split(resize &STBIR_RESIZE, split_start int, split_count int) int

pub fn stbir_resize_extended_split(resize &STBIR_RESIZE, split_start int, split_count int) int {
	return C.stbir_resize_extended_split(resize, split_start, split_count)
}

//===============================================================
//===============================================================
// Pixel Callbacks info:
//--------------------------------
//   The input callback is super flexible - it calls you with the input address
//   (based on the stride and base pointer), it gives you an optional_output
//   pointer that you can fill, or you can just return your own pointer into
//   your own data.
//
//   You can also do conversion from non-supported data types if necessary - in
//   this case, you ignore the input_ptr and just use the x and y parameters to
//   calculate your own input_ptr based on the size of each non-supported pixel.
//   (Something like the third example below.)
//
//   You can also install just an input or just an output callback by setting the
//   callback that you don't want to zero.
//
//     First example, progress: (getting a callback that you can monitor the progress):
//        void const * my_callback( void * optional_output, void const * input_ptr, int num_pixels, int x, int y, void * context )
//        {
//           percentage_done = y / input_height;
//           return input_ptr;  // use buffer from call
//        }
//
//     Next example, copying: (copy from some other buffer or stream):
//        void const * my_callback( void * optional_output, void const * input_ptr, int num_pixels, int x, int y, void * context )
//        {
//           CopyOrStreamData( optional_output, other_data_src, num_pixels * pixel_width_in_bytes );
//           return optional_output;  // return the optional buffer that we filled
//        }
//
//     Third example, input another buffer without copying: (zero-copy from other buffer):
//        void const * my_callback( void * optional_output, void const * input_ptr, int num_pixels, int x, int y, void * context )
//        {
//           void * pixels = ( (char*) other_image_base ) + ( y * other_image_stride ) + ( x * other_pixel_width_in_bytes );
//           return pixels;       // return pointer to your data without copying
//        }
//
//
//   The output callback is considerably simpler - it just calls you so that you can dump
//   out each scanline. You could even directly copy out to disk if you have a simple format
//   like TGA or BMP. You can also convert to other output types here if you want.
//
//   Simple example:
//        void const * my_output( void * output_ptr, int num_pixels, int y, void * context )
//        {
//           percentage_done = y / output_height;
//           fwrite( output_ptr, pixel_width_in_bytes, num_pixels, output_file );
//        }
//===============================================================
//===============================================================
// optional built-in profiling API
//--------------------------------
// how many clocks spent (of total_clocks) in the various resize routines, along with a string description
//    there are "resize_count" number of zones
// count of clocks and descriptions
// use after calling stbir_resize_extended (or stbir_build_samplers or stbir_build_samplers_with_splits)
// use after calling stbir_resize_extended
// use after calling stbir_resize_extended_split
//===============================================================
////   end header file   /////////////////////////////////////////////////////
