@[translated]
module C:\Users\phcre\Documents\v\imageeditor\thirdparty\stb

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
enum Stbir_pixel_layout {
	
	stbir_1_channel = 1
	stbir_2_channel = 2
	stbir_rgb = 3
// 3-chan, with order specified (for channel flipping)
	stbir_bgr = 0
// 3-chan, with order specified (for channel flipping)
	stbir_4_channel = 5
	stbir_rgba = 4
// alpha formats, where alpha is NOT premultiplied into color channels
	stbir_bgra = 6
	stbir_argb = 7
	stbir_abgr = 8
	stbir_ra = 9
	stbir_ar = 10
	stbir_rgba_pm = 11
// alpha formats, where alpha is premultiplied into color channels
	stbir_bgra_pm = 12
	stbir_argb_pm = 13
	stbir_abgr_pm = 14
	stbir_ra_pm = 15
	stbir_ar_pm = 16
	stbir_rgba_no_aw = 11
// alpha formats, where NO alpha weighting is applied at all!
	stbir_bgra_no_aw = 12
//   these are just synonyms for the _PM flags (which also do
	stbir_argb_no_aw = 13
//   no alpha weighting). These names just make it more clear
	stbir_abgr_no_aw = 14
//   for some folks).
	stbir_ra_no_aw = 15
	stbir_ar_no_aw = 16
}

//===============================================================
//  Simple-complexity API
//
//    If output_pixels is NULL (0), then we will allocate the buffer and return it to you.
//--------------------------------
fn C.stbir_resize_uint8_srgb(input_pixels &u8, input_w int, input_h int, input_stride_in_bytes int, output_pixels &u8, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &u8

pub fn stbir_resize_uint8_srgb(input_pixels &u8, input_w int, input_h int, input_stride_in_bytes int, output_pixels &u8, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &u8 {
	return C.stbir_resize_uint8_srgb(input_pixels, input_w, input_h, input_stride_in_bytes, output_pixels, output_w, output_h, output_stride_in_bytes, pixel_type)
}

fn C.stbir_resize_uint8_linear(input_pixels &u8, input_w int, input_h int, input_stride_in_bytes int, output_pixels &u8, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &u8

pub fn stbir_resize_uint8_linear(input_pixels &u8, input_w int, input_h int, input_stride_in_bytes int, output_pixels &u8, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &u8 {
	return C.stbir_resize_uint8_linear(input_pixels, input_w, input_h, input_stride_in_bytes, output_pixels, output_w, output_h, output_stride_in_bytes, pixel_type)
}

fn C.stbir_resize_float_linear(input_pixels &f32, input_w int, input_h int, input_stride_in_bytes int, output_pixels &f32, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &f32

pub fn stbir_resize_float_linear(input_pixels &f32, input_w int, input_h int, input_stride_in_bytes int, output_pixels &f32, output_w int, output_h int, output_stride_in_bytes int, pixel_type Stbir_pixel_layout) &f32 {
	return C.stbir_resize_float_linear(input_pixels, input_w, input_h, input_stride_in_bytes, output_pixels, output_w, output_h, output_stride_in_bytes, pixel_type)
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
enum Stbir_edge {
	stbir_edge_clamp = 0
	stbir_edge_reflect = 1
	stbir_edge_wrap = 2
// this edge mode is slower and uses more memory
	stbir_edge_zero = 3
}

enum Stbir_filter {
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
// User callback specified
	
}

enum Stbir_datatype {
	stbir_type_uint_8 = 0
	stbir_type_uint_8_srgb = 1
	stbir_type_uint_8_srgb_alpha = 2
// alpha channel, when present, should also be SRGB (this is very unusual)
	stbir_type_uint_16 = 3
	stbir_type_float = 4
	stbir_type_half_float = 5
}

// medium api
fn C.stbir_resize(input_pixels voidptr, input_w int, input_h int, input_stride_in_bytes int, output_pixels voidptr, output_w int, output_h int, output_stride_in_bytes int, pixel_layout Stbir_pixel_layout, data_type Stbir_datatype, edge Stbir_edge, filter Stbir_filter) voidptr

pub fn stbir_resize(input_pixels voidptr, input_w int, input_h int, input_stride_in_bytes int, output_pixels voidptr, output_w int, output_h int, output_stride_in_bytes int, pixel_layout Stbir_pixel_layout, data_type Stbir_datatype, edge Stbir_edge, filter Stbir_filter) voidptr {
	return C.stbir_resize(input_pixels, input_w, input_h, input_stride_in_bytes, output_pixels, output_w, output_h, output_stride_in_bytes, pixel_layout, data_type, edge, filter)
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
type Stbir_input_callback = Void *(void *,voidptr, int, int, int,voidptr)
// OUTPUT CALLBACK: this callback is used for output scanlines
type Stbir_output_callback = Void (void *, int, int,voidptr)
// callbacks for user installed filters
type Stbir__kernel_callback = Float (float, float,voidptr)
// centered at zero
type Stbir__support_callback = Float (float,voidptr)
// internal structure with precomputed scaling
struct STBIR_RESIZE { 
// use the stbir_resize_init and stbir_override functions to set these values for future compatibility
	user_data voidptr
	input_pixels voidptr
	input_w int
	input_h int
	input_s0 f64
	input_t0 f64
	input_s1 f64
	input_t1 f64
	input_cb &Stbir_input_callback
	output_pixels voidptr
	output_w int
	output_h int
	output_subx int
	output_suby int
	output_subw int
	output_subh int
	output_cb &Stbir_output_callback
	input_stride_in_bytes int
	output_stride_in_bytes int
	splits int
	fast_alpha int
	needs_rebuild int
	called_alloc int
	input_pixel_layout_public Stbir_pixel_layout
	output_pixel_layout_public Stbir_pixel_layout
	input_data_type Stbir_datatype
	output_data_type Stbir_datatype
	horizontal_filter Stbir_filter
	vertical_filter Stbir_filter
	horizontal_edge Stbir_edge
	vertical_edge Stbir_edge
	horizontal_filter_kernel &Stbir__kernel_callback
	horizontal_filter_support &Stbir__support_callback
	vertical_filter_kernel &Stbir__kernel_callback
	vertical_filter_support &Stbir__support_callback
	samplers &Stbir__info
}
// extended complexity api
// First off, you must ALWAYS call stbir_resize_init on your resize structure before any of the other calls!
fn C.stbir_resize_init(resize &STBIR_RESIZE, input_pixels voidptr, input_w int, input_h int, input_stride_in_bytes int, output_pixels voidptr, output_w int, output_h int, output_stride_in_bytes int, pixel_layout Stbir_pixel_layout, data_type Stbir_datatype)

pub fn stbir_resize_init(resize &STBIR_RESIZE, input_pixels voidptr, input_w int, input_h int, input_stride_in_bytes int, output_pixels voidptr, output_w int, output_h int, output_stride_in_bytes int, pixel_layout Stbir_pixel_layout, data_type Stbir_datatype) {
	C.stbir_resize_init(resize, input_pixels, input_w, input_h, input_stride_in_bytes, output_pixels, output_w, output_h, output_stride_in_bytes, pixel_layout, data_type)
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
	C.stbir_set_buffer_ptrs(resize, input_pixels, input_stride_in_bytes, output_pixels, output_stride_in_bytes)
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
	return C.stbir_set_filter_callbacks(resize, horizontal_filter, horizontal_support, vertical_filter, vertical_support)
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
// STBIR_INCLUDE_STB_IMAGE_RESIZE2_H
// (we used the comma operator to evaluate user_data, to avoid "unused parameter" warnings)
// Clang address sanitizer
// GCC and MSVC
// Always turn off automatic FMA use - use STBIR_USE_FMA if you want.
// Otherwise, this is a determinism disaster.
// override in case you don't want this behavior
// the internal pixel layout enums are in a different order, so we can easily do range comparisons of types
//   the public pixel layout is ordered in a way that if you cast num_channels (1-4) to the enum, you get something sensible
// define the public pixel layouts to not compile inside the implementation (to avoid accidental use)
// must match stbir_datatype
// STBIR_TYPE_UINT8,STBIR_TYPE_UINT8_SRGB,STBIR_TYPE_UINT8_SRGB_ALPHA,STBIR_TYPE_UINT16,STBIR_TYPE_FLOAT,STBIR_TYPE_HALF_FLOAT
// When gathering, the contributors are which source pixels contribute.
// When scattering, the contributors are which destination pixels are contributed to.
// First contributing pixel
// Last contributing pixel
// First sample index for whole filter
// Last sample index for whole filter
// widest single set of samples for an output
// First pixel of decode buffer to write to
// Last pixel of decode that will be written to
// Pixel offset into input_scanline
// starting shift in output pixel space (in pixels)
// 0 = scatter, 1 = gather with scale >= 1, 2 = gather with scale < 1
// this can be less than filter_pixel_margin, if the filter and scaling falls off
// can be two spans, if doing input subrect with clamp mode WRAP
// first_scanline is at this index in the ring buffer
// used in scatter only
// one pointer for each ring buffer
// one big buffer that we index into
// The length of an individual entry in the ring buffer. The total number of ring buffers is stbir__get_filter_pixel_width(filter)
// Total number of entries in the ring buffer.
// by default 1, but there will be N of these allocated based on the thread init you did
// Number of entries in the ring buffer that will be allocated
// count of splits
// offset within output_data
// same as channels, except on RGBA/ARGB (7), or XA/AX (3)
// min/max friendly
// From https://gist.github.com/rygorous/2203834
// 1-eps
// Clamp to [2^(-13), 1-eps]; these two values map to 0 and 1, respectively.
// The tests are carefully written so that NaNs map to 0, same as in the reference
// implementation.
// written this way to catch NaNs
// Do the table lookup and unpack bias, scale
// Grab next-highest mantissa bits and perform linear interpolation
// when downsampling and <= 32 scanlines of buffering, use gather. gather used down to 1/8th scaling for 25% win.
// when threading, what is the minimum number of scanlines for a split?
// restrict pointers for the output pointers, other loop and unroll control
// this oddly keeps msvc from unrolling a loop
// force simd off for whatever reason
// force simd off overrides everything else, so clear it all
// STBIR_SIMD
// top values can be random (not denormal or nan for perf)
// top values must be zero
// top values can be random (not denormal or nan for perf)
// top values must be zero
// not on by default to maintain bit identical simd to non-simd
// msvc inits with 8 bytes
// everything else inits with long long's
// if we detect AVX, set the simd8 defines
// avx load instruction
// not on by default to maintain bit identical simd to non-simd
// martins floorf
// martins ceilf
// top values can be random (not denormal or nan for perf)
// top values must be zero
// top values can be random (not denormal or nan for perf)
// top values must be zero
// not on by default to maintain bit identical simd to non-simd (and also x64 no madd to arm madd)
// top values can be random (not denormal or nan for perf)
// top values must be zero
// top values can be random (not denormal or nan for perf)
// top values must be zero
// SSE2/NEON/WASM
// NO SIMD
// no NEON, or 32-bit ARM for MSVC
// Fabian's half float routines, see: https://gist.github.com/rygorous/2156668
// exponent/mantissa bits
// exponent adjust
// make sure Inf/NaN survive
// sign bit
// result is Inf or NaN (all exponent bits set)
// NaN->qNaN and Inf->Inf
// (De)normalized number or zero
// resulting FP16 is subnormal or zero
// use a magic value to align our 10 mantissa bits at the bottom of
// the float. as long as FP addition is round-to-nearest-even this
// just works.
// and one integer subtract of the bias later, we have our final float!
// resulting mantissa is odd
// update exponent, rounding bias part 1
// rounding bias part 2
// take the bits!
// Fabian's half float routines, see: https://gist.github.com/rygorous/2156668
// ~38 SSE2 ops for 8 values
// Fabian's round-to-nearest-even float to half
// ~48 SSE2 ops for 8 output
// all FP32 values >=this round to +inf
// smallest FP32 that yields a normalized FP16
// adjust exponent and add mantissa rounding
// the cast is "free" (extra bypass latency, but no thruput hit)
// is this a NaN?
// (sub)normalized or special?
// output for specials
// "result is subnormal" path
// magic value to round output mantissa
// subtract out bias
// "result is normal" path
// shift bit 13 (mantissa LSB) to sign
// -1 if FP16 mantissa odd, else 0
// if mantissa LSB odd, bias towards rounding up (RTNE)
// rounded result
// combine the two non-specials
// merge in specials as well
// the cast is "free" (extra bypass latency, but no thruput hit)
// is this a NaN?
// (sub)normalized or special?
// output for specials
// "result is subnormal" path
// magic value to round output mantissa
// subtract out bias
// "result is normal" path
// shift bit 13 (mantissa LSB) to sign
// -1 if FP16 mantissa odd, else 0
// if mantissa LSB odd, bias towards rounding up (RTNE)
// rounded result
// combine the two non-specials
// merge in specials as well
// 64-bit ARM on MSVC (not clang)
// 64-bit ARM
// WASM or 32-bit ARM on MSVC/clang
//   Basically, in simd mode, we unroll the proper amount, and we don't want
//   the non-simd remnant loops to be unroll because they only run a few times
//   Adding this switch saves about 5K on clang which is Captain Unroll the 3rd.
// override normal use of memcpy with much simpler copy (faster and smaller with our sized copies)
// check overlaps
// do one unaligned to get us aligned for the stream out below
// do one unaligned to get us aligned for the stream out below
// memcpy that is specically intentionally overlapping (src is smaller then dest, so can be
//   a normal forward copy, bytes is divisible by 4 and bytes is greater than or equal to
//   the diff between dest and src)
// is the overlap more than 16 away?
// no SSE2
// when in scalar mode, we let unrolling happen, so this macro just does the __restrict
// SSE2
// non msvc
// msvc
// x64, arm
// x64, arm
// STBIR_PROFILE_FUNC
// super light-weight micro profiler
// for thread data
// for build data
// no profile
// stbir_profile
// support VC6 for Sean
// For memcpy
// memcpy that is specifically intentionally overlapping (src is smaller then dest, so can be
//   a normal forward copy, bytes is divisible by 4 and bytes is greater than or equal to
//   the diff between dest and src)
// is the overlap more than 8 away?
// This is the maximum number of input samples that can affect an output sample
// with the given filter from the output pixel's perspective
// upscale
// this is how many coefficents per run of the filter (which is different
//   from the filter_pixel_width depending on if we are scattering or gathering)
// NOTREACHED
// NOTREACHED
// NOTREACHED
// STBIR_EDGE_CLAMP
// STBIR_EDGE_REFLECT
// STBIR_EDGE_WRAP
// STBIR_EDGE_ZERO
// avoid per-pixel switch
// get information on the extents of a sampler
// if we find a new min, only scan another filter width
// if we find a new max, only scan another filter width
// now calculate how much into the margins we really read
// index 1 is margin pixel extents (how many pixels we hang over the edge)
// index 2 is pixels read from the input
// default to no other input range
// don't have to do edge calc for zero clamp
// convert margin pixels to the pixels within the input (min and max)
// merge the left margin pixel region if it connects within 4 pixels of main pixel region
// merge the right margin pixel region if it connects within 4 pixels of main pixel region
// you get two ranges when you have the WRAP edge mode and you are doing just the a piece of the resize
//   so you need to get a second run of pixels from the opposite side of the scanline (which you
//   wouldn't need except for WRAP)
// if we can't merge the min_left range, add it as a second range
// don't need to copy the left margin, since we are directly decoding into the margin
// if we can't merge the min_left range, add it as a second range
// don't need to copy the right margin, since we are directly decoding into the margin
// point sample mode can span a value *right* at 0.5, and cause these to cross
// Looping through out pixels
// make sure we never generate a range larger than our precalculated coeff width
//   this only happens in point sample mode, but it's a good safe thing to do anyway
// kill denormals
// if we're at the front, just eat zero contributors
// there should be at least one contrib
// make sure is fully zero (should keep denormals away)
// kills trailing zeros
// before the end
// before the front?
// clear in-betweens coeffs if there are any
// Loop through the input pixels
// clamp or exit if we are using polyphase filtering, and the limit is up
// when polyphase, you only have to do coeffs up to the numerator count
// don't do any extra work, clamp last pixel at numerator too
// kill the coeff if it's too small (avoid denormals)
// is this the first time this output pixel has been seen?  Init it.
// ensure we have only advanced one at time
// insert on end (always in order)
// if the first coefficent is zero, then zap it for this coeffs
// ensure that when we zap, we're at the 2nd pos
// weight all the coeffs for each sample
// add all contribs
// check for wonky weights
// rescale
// all coeffs are extremely small, just zero it
// if the total isn't 1.0, rescale everything
// scale them all
// if we have a rational for the scale, we can exploit the polyphaseness to not calculate
//   most of the coefficients, so we copy them here
// in zero edge mode, just remove out of bounds contribs completely (since their weights are accounted for now)
// shrink the right side if necessary
// shrink the left side
// now move down the weights
// for clamp and reflect, calculate the true inbounds position (based on edge type) and just add that to the existing weight
// right hand side first
// now check left hand edge
// reinsert the coeffs with it reflected or clamped (insert accumulates, if the coeffs exist)
// save it, since we didn't do the final one (i==n0), because there might be too many coeffs to hold (before we resize)!
// now slide all the coeffs down (since we have accumulated them in the positive contribs) and reset the first contrib
// now that we have shrunk down the contribs, we insert the first one safely
// re-zero out unused coefficients (if any)
// only used in an assert
// some horizontal routines read one float off the end (which is then masked off), so put in a sentinal so we don't read an snan or denormal
// the minimum we might read for unrolled filters widths is 12. So, we need to
//   make sure we never read outside the decode buffer, by possibly moving
//   the sample area back into the scanline, and putting zeros weights first.
// we start on the right edge and check until we're well past the possible
//   clip area (2*widest).
// go until no chance of clipping (this is usually less than 8 lops)
// might we clip??
// if range is larger than 12, it will be handled by generic loops that can terminate on the exact length
//   of this contrib n1, instead of a fixed widest amount - so calculate this
// how far will be read in the n_coeff loop (which depends on the widest count mod4);
// the n_coeff loops do a minimum amount of coeffs, so factor that in!
// now see if we still clip with the refined range
// move the coeffs over
// zero new positions
// set new start point
// how far will be read in the n_coeff loop (which depends on the widest count mod4);
// the n_coeff loops do a minimum amount of coeffs, so factor that in!
// gather upsample
// scatter downsample (only on vertical)
// gather downsample
// if this is a scatter, we do a downsample gather to get the coeffs, and then pivot after
// check if we are using the same gather downsample on the horizontal as this vertical,
//   if so, then we don't have to generate them, we can just pivot from the horizontal.
// if this is a scatter (vertical only), then we need to pivot the coeffs
// skip zero and denormals - must skip zeros to avoid adding coeffs beyond scatter_coefficient_width
//   (which happens when pivoting from horizontal, which might have dummy zeros)
// if we are skipping over several contributors, we need to clear the skipped ones
// now clear any unset contribs
//========================================================================================================
// scanline decoders and encoders
// fancy alpha means we expand to keep both premultipied and non-premultiplied color channels
// decode buffer aligned to end of out_buffer
// fancy alpha is stored internally as R G B A Rpm Gpm Bpm
// might be one last odd pixel
//  for fancy alpha, turns into: [X A Xpm][X A Xpm],etc
// fancy RGBA is stored internally as R G B A Rpm Gpm Bpm
//  format: [X A Xpm][X A Xpm] etc
// few last pixels remnants
// only used in RGB->BGR or BGR->RGB
// do we have two argument swizzles?
// on arm64 8 instructions, no overlapping stores
// 26 instructions on x64
// stores overlap, need to be in order, 
// 16 instructions
// if we are on edge_zero, and we get in here with an out of bounds n, then the calculate filters has failed
// read directly out of input plane by default
// if we have an input callback, call it to get the input data
// call the callback with a temp buffer (that they can choose to use or not).  the temp is just right aligned memory in the decode_buffer itself
// convert the pixels info the float decode_buffer, (we index from end_decode, so that when channels<effective_channels, we are right justified in the buffer)
// handle the edge_wrap filter (all other types are handled back out at the calculate_filter stage)
// basically the idea here is that if we have the whole scanline in memory, we don't redecode the
//   wrapped edge pixels, and instead just memcpy them from the scanline into the edge positions
// this code only runs if we're in edge_wrap, and we're doing the entire scanline
// left edge start x
// right edge
// do each margin
//=================
// Do 1 channel horizontal routines
//=================
// Do 2 channel horizontal routines
// this weird order of add matches the simd
//=================
// Do 3 channel horizontal routines
// we're loading from the XXXYYY decode by -1 to get the XXXYYY into different halves of the AVX reg fyi
//=================
// Do 4 channel horizontal routines
//=================
// Do 7 channel horizontal routines
// include all of the vertical resamplers (both scatter and gather versions)
// un-alpha weight if we need to
// write directly into output by default
// if we have an output callback, we first convert the decode buffer in place (and then hand that to the callback)
// convert into the output buffer
// if we have an output callback, call it to send the data
// Get the ring buffer pointer for an index
// Get the specified scan line from the ring buffer
// loop over the contributing scanlines and scale into the buffer
// call the N scanlines at a time function (up to 8 scanlines of blending at once)
// Now resample the gathered vertical data in the horizontal axis into the encode buffer
// Decode the nth scanline from the source image into the decode buffer.
// update new end scanline
// get ring buffer
// Now resample it into the ring buffer.
// Now it's sitting in the ring buffer ready to be used as source for the vertical sampling.
// initialize the ring buffer for gathering
// means "empty"
// make sure the indexing hasn't broken
// Load in new scanlines
// make sure there was room in the ring buffer when we add new scanlines
// Decode the nth scanline from the source image into the decode buffer.
// Now all buffers should be ready to write a row of vertical sampling, so do it.
// evict a scanline out into the output buffer
// dump the scanline out
// mark it as empty
// advance the first scanline
// evict a scanline out into the output buffer
// Now resample it into the buffer.
// dump the scanline out
// mark it as empty
// advance the first scanline
// make sure runs are of the same type
// call the scatter to N scanlines at a time function (up to 8 scanlines of scattering at once)
// may do multiple split counts
// adjust for starting offset start_input_y
// initialize the ring buffer for scattering
// mark all the buffers as empty to start
// only used on scatter
// do the loop in input space
// keep track of the range actually seen for the next resize
// clip the region
// if very first scanline, init the index
// Decode the nth scanline from the source image into the decode buffer.
// When horizontal first, we resample horizontally into the vertical buffer before we scatter it out
// Now it's sitting in the buffer ready to be distributed into the ring buffers.
// evict from the ringbuffer, if we need are full
// Now the horizontal buffer is ready to write to all ring buffer rows, so do it.
// update the end of the buffer
// now evict the scanlines that are left over in the ring buffer
// update the end_input_y if we do multiple resizes with the same data
// set filter
// default to downsample
// Gather is always better, but in extreme downsamples, you have to most or all of the data in memory
//    For horizontal, we always have all the pixels, so we always use gather here (always_gather==1).
//    For vertical, we use gather if scaling up (which means we will have samp->filter_pixel_width
//    scanlines in memory at once).
// pre calculate stuff based on the above
// filter_pixel_width is the conservative size in pixels of input that affect an output pixel.
//   In rare cases (only with 2 pix to 1 pix with the default filters), it's possible that the 
//   filter will extend before or after the scanline beyond just one extra entire copy of the 
//   scanline (we would hit the edge twice). We don't let you do that, so we clamp the total 
//   width to 3x the total of input pixel (once for the scanline, once for the left side 
//   overhang, and once for the right side). We only do this for edge mode, since the other 
//   modes can just re-edge clamp back in again.
// This is how much to expand buffers to account for filters seeking outside
// the image boundaries.
// filter_pixel_margin is the amount that this filter can overhang on just one side of either 
//   end of the scanline (left or the right). Since we only allow you to overhang 1 scanline's 
//   worth of pixels, we clamp this one side of overhang to the input scanline size. Again, 
//   this clamping only happens in rare cases with the default filters (2 pix to 1 pix). 
// extra sizeof(float) is padding
// downsample gather, refine
// get a conservative area of the input range
// now go through the margin to the start of area to find bottom
// now go through the end of the area through the margin to find top
// if we are wrapping, and we are very close to the image size (so the edges might merge), just use the scanline up to the edge
// for non-edge-wrap modes, we never read over the edge, so clamp
// scatter range (updated to minimum as you run it)
// avx in 3 channel mode needs one float at the start of the buffer
// avx in 3 channel mode needs one float at the start of the buffer
// there are six resize classifications: 0 == vertical scatter, 1 == vertical gather < 1x scale, 2 == vertical gather 1x-2x scale, 4 == vertical gather < 3x scale, 4 == vertical gather > 3x scale, 5 == <=4 pixel height, 6 == <=4 pixel wide column
// 5 = 0=1chan, 1=2chan, 2=3chan, 3=4chan, 4=7chan
// structure that allow us to query and override info for training the costs
// 0 = no control, 1 = force hori, 2 = force vert
// Figure out whether to scale along the horizontal or vertical first.
//   This only *super* important when you are scaling by a massively
//   different amount in the vertical vs the horizontal (for example, if
//   you are scaling by 2x in the width, and 0.5x in the height, then you
//   want to do the vertical scale first, because it's around 3x faster
//   in that order.
//
//   In more normal circumstances, this makes a 20-40% differences, so
//     it's good to get right, but not critical. The normal way that you
//     decide which direction goes first is just figuring out which
//     direction does more multiplies. But with modern CPUs with their
//     fancy caches and SIMD and high IPC abilities, so there's just a lot
//     more that goes into it.
//
//   My handwavy sort of solution is to have an app that does a whole
//     bunch of timing for both vertical and horizontal first modes,
//     and then another app that can read lots of these timing files
//     and try to search for the best weights to use. Dotimings.c
//     is the app that does a bunch of timings, and vf_train.c is the
//     app that solves for the best weights (and shows how well it
//     does currently).
// categorize the resize into buckets
// use the right weights
// this is the costs when you don't take into account modern CPUs with high ipc and simd and caches - wish we had a better estimate
// use computation estimate to decide vertical first or not
// save these, if requested
// and this allows us to override everything for testing (see dotiming.c)
// layout lookups - must match stbir_internal_pixel_layout
// 1ch, 2ch, rgb, bgr, 4ch
// RGBA,BGRA,ARGB,ABGR,RA,AR
// RGBA_PM,BGRA_PM,ARGB_PM,ABGR_PM,RA_PM,AR_PM
// the internal pixel layout enums are in a different order, so we can easily do range comparisons of types
//   the public pixel layout is ordered in a way that if you cast num_channels (1-4) to the enum, you get something sensible
// 0=none, 1=simple, 2=fancy
// first figure out what type of alpha weighting to use (if any)
// no alpha weighting on point sampling
// input premult, output non-premult
// input non-premult, output premult
// channel in and out count must match currently
// get vertical first
// sometimes read one float off in some of the unrolled loops (with a weight of zero coeff, so it doesn't have an effect)
// extra float for padding
// avx in 3 channel mode needs one float at the start of the buffer (only with separate allocations)
// extra float for padding
// if we do vertical first, the ring buffer holds a whole decoded line
// avoid 4k alias
// One extra entry because floating point precision problems sometimes cause an extra to be necessary.
// we never need more ring buffer entries than the scanlines we're outputting when in scatter mode
// The vertical buffer is used differently, depending on whether we are scattering
//   the vertical scanlines, or gathering them.
//   If scattering, it's used at the temp buffer to accumulate each output.
//   If gathering, it's just the output buffer.
// extra float for padding
// we make two passes through this loop, 1st to add everything up, 2nd to allocate and init
// initialize info fields
// setup alpha weight functions
// handle alpha weighting functions and overrides
// high quality alpha multiplying on the way in, dividing on the way out
// fast alpha multiplying on the way in, dividing on the way out
// fast alpha on the way in, leave in premultiplied form on way out
// incoming is premultiplied, fast alpha dividing on the way out - non-premultiplied output
// handle 3-chan color flipping, using the alpha weight path
// do the flipping on the smaller of the two ends
// get all the per-split buffers
// avx in 3 channel mode needs one float at the start of the buffer
// avx in 3 channel mode needs one float at the start of the buffer
// alloc memory for to-be-pivoted coeffs (if necessary)
// when in vertical scatter mode, we first build the coefficients in gather mode, and then pivot after,
//   that means we need two buffers, so we try to use the decode buffer and ring buffer for this. if that
//   is too small, we just allocate extra memory to use as this temp.
// avx in 3 channel mode needs one float at the start of the buffer
// ring+decode memory is too small, so allocate temp memory
// are the two filters identical?? (happens a lot with mipmap generation)
// everything matches, but vertical is scatter, horizontal is gather, use horizontal coeffs for vertical pivot coeffs
// setup the horizontal gather functions
// start with defaulting to the n_coeffs functions (specialized on channels and remnant leftover)
// but if the number of coeffs <= 12, use another set of special cases. <=12 coeffs is any enlarging resize, or shrinking resize down to about 1/3 size
// get exact extents
// pack the horizontal coeffs
// setup the vertical split ranges
// now we know precisely how many entries we need
// we never need more ring buffer entries than the scanlines we're outputting
// a few of the horizontal gather functions read past the end of the decode (but mask it out), 
//   so put in normal values so no snans or denormals accidentally sneak in (also, in the ring 
//   buffer for vertical first)
// avx in 3 channel mode needs one float at the start of the buffer, so we snap back for clearing
// is this the first time through loop?
// success
// 1ch-4ch 
// RGBA 
// BGRA 
// ARGB 
// ABGR 
// RA   
// AR   
// RGBA 
// BGRA 
// ARGB 
// ABGR 
// RA   
// AR   
// 1ch-4ch 
// RGBA 
// BGRA 
// ARGB 
// ABGR 
// RA   
// AR   
// RGBA 
// BGRA 
// ARGB 
// ABGR 
// RA   
// AR   
// if we're completely point sampling, then we can turn off SRGB
// recalc the output and input strides
// calc offset
// setup the input format converters
// check if we can run unscaled - 0-255.0/0-65535.0 instead of 0-1.0 (which is a tiny bit faster when doing linear 8->8 or 16->16)
// don't short circuit when alpha weighting (get everything to 0-1.0 as usual)
// setup the output format converters
// check if we can run unscaled - 0-255.0/0-65535.0 instead of 0-1.0 (which is a tiny bit faster when doing linear 8->8 or 16->16)
// don't short circuit when alpha weighting (get everything to 0-1.0 as usual)
// do left/top edge
// is negative
// increases u0
// do right/bot edge
// is negative
// decrease u1
// converts a double to a rational that has less than one float bit of error (returns 0 if unable to do so)
// limit_denom (1) or limit numer (0)
// scale to past float error range
// keep refining, but usually stops in a few loops - usually 5 for bad cases
// hit limit, break out and do best full range estimate
// is the current error less than 1 bit of a float? if so, we're done
// yup, found it
// no more refinement bits left? break out and do full range estimate
// gcd the estimate bits
// move remainders
// move remainders
// we didn't fine anything good enough for float, use a full range estimate
// null area
// are either of the ranges completely out of bounds?
// figure out the scaling to use
// save scale before clipping
// clip output area to left/right output edges (and adjust input area)
// recalc input area
// after clipping do we have zero input area?
// calculate and store the starting source offsets in output pixel space
// stride can be zero
// stride can be zero
// You can update parameters any time after resize_init
// by default, datatype from resize_init
// no callbacks by default
// pass back STBIR_RESIZE* by default
// CLAMP by default
// STBIR_DEFAULT_FILTER_UPSAMPLE/DOWNSAMPLE by default
// sets new pixel layouts
// sets alpha speed
// sets input region (full region by default)
// are we inbounds?
// sets input region (full region by default)
// are we inbounds?
// sets both regions (full regions by default)
// are we inbounds?
// used to contain building profile info before everything is allocated
// have we already built the samplers?
// do horizontal clip and scale calcs
// do vertical clip and scale calcs
// if nothing to do, just return
// each split should be a minimum of 4 scanlines (handwavey choice)
// update anything that can be changed without recalcing samplers
// remember allocated state
// if build_samplers succeeded (above), but there are no samplers set, then
//   the area to stretch into was zero pixels, so don't do anything and return
//   success
// didn't build anything - clear it
// do resize
// if we alloced, then free
// if we're just doing the whole thing, call full
// you **must** build samplers first when using split resize
// do resize
// sum up the profile from all the splits
// STBIR_PROFILE
// STB_IMAGE_RESIZE_IMPLEMENTATION
// STB_IMAGE_RESIZE_HORIZONTALS&STB_IMAGE_RESIZE_DO_VERTICALS
// we reinclude the header file to define all the horizontal functions
//   specializing each function for the number of coeffs is 20-40% faster *OVERALL*
// by including the header file again this way, we can still debug the functions
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// only use first 4
// do the remnants
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// only use first 4
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// backup and do last couple
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// only use first 4
// do the remnants
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// only use first 4
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// backup and do last couple
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// try to do blocks of 4 when you can
// doesn't divide cleanly by four
// do the remnants
// check single channel one weight
// prefetch four loop iterations ahead (doesn't affect much for small resizes, but helps with big ones)
// !STB_IMAGE_RESIZE_DO_VERTICALS
// HORIZONALS
// STB_IMAGE_RESIZE_DO_HORIZONTALS/VERTICALS/CODERS
//
//------------------------------------------------------------------------------
//This software is available under 2 licenses -- choose whichever you prefer.
//------------------------------------------------------------------------------
//ALTERNATIVE A - MIT License
//Copyright (c) 2017 Sean Barrett
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//of the Software, and to permit persons to whom the Software is furnished to do
//so, subject to the following conditions:
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//------------------------------------------------------------------------------
//ALTERNATIVE B - Public Domain (www.unlicense.org)
//This is free and unencumbered software released into the public domain.
//Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
//software, either in source code form or as a compiled binary, for any purpose,
//commercial or non-commercial, and by any means.
//In jurisdictions that recognize copyright laws, the author or authors of this
//software dedicate any and all copyright interest in the software to the public
//domain. We make this dedication for the benefit of the public at large and to
//the detriment of our heirs and successors. We intend this dedication to be an
//overt act of relinquishment in perpetuity of all present and future rights to
//this software under copyright law.
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//------------------------------------------------------------------------------
//
