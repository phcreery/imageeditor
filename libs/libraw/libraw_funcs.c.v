
module libraw

import builtin.wchar

// -* C++ -*
// *File: libraw.h
// *Copyright 2008-2024 LibRaw LLC (info@libraw.org)
// *Created: Sat Mar  8, 2008
// *
// *LibRaw C++ interface
// *
//
//LibRaw is free software; you can redistribute it and/or modify
//it under the terms of the one of two licenses as you choose:
//
//1. GNU LESSER GENERAL PUBLIC LICENSE version 2.1
//   (See file LICENSE.LGPL provided in LibRaw distribution archive for details).
//
//2. COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0
//   (See file LICENSE.CDDL provided in LibRaw distribution archive for details).
//
//
// maximum file size to use LibRaw_file_datastream (fully buffered) I/O 
// better WIN32 defines 
// better WIN32 defines 
// Win32 API 
// DLLs: Microsoft or Intel compiler 
// wchar_t*API for std::filebuf 
fn C.libraw_strerror(errorcode int) &i8

pub fn libraw_strerror(errorcode int) &i8 {
	return C.libraw_strerror(errorcode)
}

fn C.libraw_strprogress(arg0 int) &i8

pub fn libraw_strprogress(arg0 int) &i8 {
	return C.libraw_strprogress(arg0)
}

// LibRaw C API 
fn C.libraw_init(flags ConstructorFlags) &Libraw_data_t

pub fn libraw_init(flags ConstructorFlags) &Libraw_data_t {
	return C.libraw_init(flags)
}

fn C.libraw_open_file(arg0 &Libraw_data_t, arg1 &i8) LibRawErrors

pub fn libraw_open_file(ctx &Libraw_data_t, file string) LibRawErrors {
	// return C.libraw_open_file(arg0, arg1)
	return C.libraw_open_file(ctx, file.str)
}

// Character = wchar_t in https://github.com/vlang/v/blob/master/vlib/builtin/wchar/wchar.c.v
fn C.libraw_open_wfile(arg0 &Libraw_data_t, arg1 &wchar.Character) int
// fn C.libraw_open_wfile(arg0 &Libraw_data_t, arg1 &char) int

pub fn libraw_open_wfile(arg0 &Libraw_data_t, arg1 &wchar.Character) int {
// pub fn libraw_open_wfile(arg0 &Libraw_data_t, arg1 &char) int {
	return C.libraw_open_wfile(arg0, arg1)
}

fn C.libraw_open_buffer(arg0 &Libraw_data_t, buffer voidptr, size usize) int

pub fn libraw_open_buffer(arg0 &Libraw_data_t, buffer voidptr, size usize) int {
	return C.libraw_open_buffer(arg0, buffer, size)
}

fn C.libraw_open_bayer(lr &Libraw_data_t, data &u8, datalen u32, _raw_width Ushort, _raw_height Ushort, _left_margin Ushort, _top_margin Ushort, _right_margin Ushort, _bottom_margin Ushort, procflags u8, bayer_battern u8, unused_bits u32, otherflags u32, black_level u32) int

pub fn libraw_open_bayer(lr &Libraw_data_t, data &u8, datalen u32, _raw_width Ushort, _raw_height Ushort, _left_margin Ushort, _top_margin Ushort, _right_margin Ushort, _bottom_margin Ushort, procflags u8, bayer_battern u8, unused_bits u32, otherflags u32, black_level u32) int {
	return C.libraw_open_bayer(lr, data, datalen, _raw_width, _raw_height, _left_margin, _top_margin, _right_margin, _bottom_margin, procflags, bayer_battern, unused_bits, otherflags, black_level)
}

fn C.libraw_unpack(arg0 &Libraw_data_t) LibRawErrors

pub fn libraw_unpack(arg0 &Libraw_data_t) LibRawErrors {
	return C.libraw_unpack(arg0)
}

fn C.libraw_unpack_thumb(arg0 &Libraw_data_t) int

pub fn libraw_unpack_thumb(arg0 &Libraw_data_t) int {
	return C.libraw_unpack_thumb(arg0)
}

fn C.libraw_unpack_thumb_ex(arg0 &Libraw_data_t, arg1 int) int

pub fn libraw_unpack_thumb_ex(arg0 &Libraw_data_t, arg1 int) int {
	return C.libraw_unpack_thumb_ex(arg0, arg1)
}

fn C.libraw_recycle_datastream(arg0 &Libraw_data_t)

pub fn libraw_recycle_datastream(arg0 &Libraw_data_t) {
	C.libraw_recycle_datastream(arg0)
}

fn C.libraw_recycle(arg0 &Libraw_data_t)

pub fn libraw_recycle(arg0 &Libraw_data_t) {
	C.libraw_recycle(arg0)
}

fn C.libraw_close(arg0 &Libraw_data_t)

pub fn libraw_close(arg0 &Libraw_data_t) {
	C.libraw_close(arg0)
}

fn C.libraw_subtract_black(arg0 &Libraw_data_t)

pub fn libraw_subtract_black(arg0 &Libraw_data_t) {
	C.libraw_subtract_black(arg0)
}

fn C.libraw_raw2image(arg0 &Libraw_data_t) LibRawErrors

pub fn libraw_raw2image(arg0 &Libraw_data_t) LibRawErrors {
	return C.libraw_raw2image(arg0)
}

fn C.libraw_free_image(arg0 &Libraw_data_t)

pub fn libraw_free_image(arg0 &Libraw_data_t) {
	C.libraw_free_image(arg0)
}

// version helpers 
fn C.libraw_version() &char

pub fn libraw_version() string {
	return unsafe { cstring_to_vstring(C.libraw_version()) }
}

fn C.libraw_versionNumber() int

pub fn libraw_version_number() int {
	return C.libraw_versionNumber()
}

// Camera list 
fn C.libraw_cameraList() &&u8

pub fn libraw_camera_list() &&u8 {
	return C.libraw_cameraList()
}

fn C.libraw_cameraCount() int

pub fn libraw_camera_count() int {
	return C.libraw_cameraCount()
}

// helpers 
fn C.libraw_set_exifparser_handler(arg0 &Libraw_data_t, cb Exif_parser_callback, datap voidptr)

pub fn libraw_set_exifparser_handler(arg0 &Libraw_data_t, cb Exif_parser_callback, datap voidptr) {
	C.libraw_set_exifparser_handler(arg0, cb, datap)
}

fn C.libraw_set_dataerror_handler(arg0 &Libraw_data_t, func Data_callback, datap voidptr)

pub fn libraw_set_dataerror_handler(arg0 &Libraw_data_t, func Data_callback, datap voidptr) {
	C.libraw_set_dataerror_handler(arg0, func, datap)
}

fn C.libraw_set_progress_handler(arg0 &Libraw_data_t, cb Progress_callback, datap voidptr)

pub fn libraw_set_progress_handler(arg0 &Libraw_data_t, cb Progress_callback, datap voidptr) {
	C.libraw_set_progress_handler(arg0, cb, datap)
}

fn C.libraw_unpack_function_name(lr &Libraw_data_t) &i8

pub fn libraw_unpack_function_name(lr &Libraw_data_t) &i8 {
	return C.libraw_unpack_function_name(lr)
}

fn C.libraw_get_decoder_info(lr &Libraw_data_t, d &Libraw_decoder_info_t) int

pub fn libraw_get_decoder_info(lr &Libraw_data_t, d &Libraw_decoder_info_t) int {
	return C.libraw_get_decoder_info(lr, d)
}

fn C.libraw_COLOR(arg0 &Libraw_data_t, row int, col int) int

pub fn libraw_color(arg0 &Libraw_data_t, row int, col int) int {
	return C.libraw_COLOR(arg0, row, col)
}

fn C.libraw_capabilities() u32

pub fn libraw_capabilities() u32 {
	return C.libraw_capabilities()
}

fn C.libraw_adjust_to_raw_inset_crop(lr &Libraw_data_t, mask u32, maxcrop f32) int

pub fn libraw_adjust_to_raw_inset_crop(lr &Libraw_data_t, mask u32, maxcrop f32) int {
	return C.libraw_adjust_to_raw_inset_crop(lr, mask, maxcrop)
}

// DCRAW compatibility 
fn C.libraw_adjust_sizes_info_only(arg0 &Libraw_data_t) int

pub fn libraw_adjust_sizes_info_only(arg0 &Libraw_data_t) int {
	return C.libraw_adjust_sizes_info_only(arg0)
}

fn C.libraw_dcraw_ppm_tiff_writer(lr &Libraw_data_t, filename &i8) int

pub fn libraw_dcraw_ppm_tiff_writer(lr &Libraw_data_t, filename &i8) int {
	return C.libraw_dcraw_ppm_tiff_writer(lr, filename)
}

fn C.libraw_dcraw_thumb_writer(lr &Libraw_data_t, fname &i8) int

pub fn libraw_dcraw_thumb_writer(lr &Libraw_data_t, fname &i8) int {
	return C.libraw_dcraw_thumb_writer(lr, fname)
}

fn C.libraw_dcraw_process(lr &Libraw_data_t) LibRawErrors

pub fn libraw_dcraw_process(lr &Libraw_data_t) LibRawErrors {
	return C.libraw_dcraw_process(lr)
}

fn C.libraw_dcraw_make_mem_image(lr &Libraw_data_t, errc &LibRawErrors) &Libraw_processed_image_t

pub fn libraw_dcraw_make_mem_image(lr &Libraw_data_t, errc &LibRawErrors) &Libraw_processed_image_t {
	return C.libraw_dcraw_make_mem_image(lr, errc)
}

fn C.libraw_dcraw_make_mem_thumb(lr &Libraw_data_t, errc &int) &Libraw_processed_image_t

pub fn libraw_dcraw_make_mem_thumb(lr &Libraw_data_t, errc &int) &Libraw_processed_image_t {
	return C.libraw_dcraw_make_mem_thumb(lr, errc)
}

fn C.libraw_dcraw_clear_mem(arg0 &Libraw_processed_image_t)

pub fn libraw_dcraw_clear_mem(arg0 &Libraw_processed_image_t) {
	C.libraw_dcraw_clear_mem(arg0)
}

// getters/setters used by 3DLut Creator 
fn C.libraw_set_demosaic(lr &Libraw_data_t, value int)

pub fn libraw_set_demosaic(lr &Libraw_data_t, value int) {
	C.libraw_set_demosaic(lr, value)
}

fn C.libraw_set_output_color(lr &Libraw_data_t, value int)

pub fn libraw_set_output_color(lr &Libraw_data_t, value int) {
	C.libraw_set_output_color(lr, value)
}

fn C.libraw_set_adjust_maximum_thr(lr &Libraw_data_t, value f32)

pub fn libraw_set_adjust_maximum_thr(lr &Libraw_data_t, value f32) {
	C.libraw_set_adjust_maximum_thr(lr, value)
}

fn C.libraw_set_user_mul(lr &Libraw_data_t, index int, val f32)

pub fn libraw_set_user_mul(lr &Libraw_data_t, index int, val f32) {
	C.libraw_set_user_mul(lr, index, val)
}

fn C.libraw_set_output_bps(lr &Libraw_data_t, value int)

pub fn libraw_set_output_bps(lr &Libraw_data_t, value int) {
	C.libraw_set_output_bps(lr, value)
}

fn C.libraw_set_gamma(lr &Libraw_data_t, index int, value f32)

pub fn libraw_set_gamma(lr &Libraw_data_t, index int, value f32) {
	C.libraw_set_gamma(lr, index, value)
}

fn C.libraw_set_no_auto_bright(lr &Libraw_data_t, value int)

pub fn libraw_set_no_auto_bright(lr &Libraw_data_t, value int) {
	C.libraw_set_no_auto_bright(lr, value)
}

fn C.libraw_set_bright(lr &Libraw_data_t, value f32)

pub fn libraw_set_bright(lr &Libraw_data_t, value f32) {
	C.libraw_set_bright(lr, value)
}

fn C.libraw_set_highlight(lr &Libraw_data_t, value int)

pub fn libraw_set_highlight(lr &Libraw_data_t, value int) {
	C.libraw_set_highlight(lr, value)
}

fn C.libraw_set_fbdd_noiserd(lr &Libraw_data_t, value int)

pub fn libraw_set_fbdd_noiserd(lr &Libraw_data_t, value int) {
	C.libraw_set_fbdd_noiserd(lr, value)
}

fn C.libraw_get_raw_height(lr &Libraw_data_t) int

pub fn libraw_get_raw_height(lr &Libraw_data_t) int {
	return C.libraw_get_raw_height(lr)
}

fn C.libraw_get_raw_width(lr &Libraw_data_t) int

pub fn libraw_get_raw_width(lr &Libraw_data_t) int {
	return C.libraw_get_raw_width(lr)
}

fn C.libraw_get_iheight(lr &Libraw_data_t) int

pub fn libraw_get_iheight(lr &Libraw_data_t) int {
	return C.libraw_get_iheight(lr)
}

fn C.libraw_get_iwidth(lr &Libraw_data_t) int

pub fn libraw_get_iwidth(lr &Libraw_data_t) int {
	return C.libraw_get_iwidth(lr)
}

fn C.libraw_get_cam_mul(lr &Libraw_data_t, index int) f32

pub fn libraw_get_cam_mul(lr &Libraw_data_t, index int) f32 {
	return C.libraw_get_cam_mul(lr, index)
}

fn C.libraw_get_pre_mul(lr &Libraw_data_t, index int) f32

pub fn libraw_get_pre_mul(lr &Libraw_data_t, index int) f32 {
	return C.libraw_get_pre_mul(lr, index)
}

fn C.libraw_get_rgb_cam(lr &Libraw_data_t, index1 int, index2 int) f32

pub fn libraw_get_rgb_cam(lr &Libraw_data_t, index1 int, index2 int) f32 {
	return C.libraw_get_rgb_cam(lr, index1, index2)
}

fn C.libraw_get_color_maximum(lr &Libraw_data_t) int

pub fn libraw_get_color_maximum(lr &Libraw_data_t) int {
	return C.libraw_get_color_maximum(lr)
}

fn C.libraw_set_output_tif(lr &Libraw_data_t, value int)

pub fn libraw_set_output_tif(lr &Libraw_data_t, value int) {
	C.libraw_set_output_tif(lr, value)
}

fn C.libraw_get_iparams(lr &Libraw_data_t) &Libraw_iparams_t

pub fn libraw_get_iparams(lr &Libraw_data_t) &Libraw_iparams_t {
	return C.libraw_get_iparams(lr)
}

fn C.libraw_get_lensinfo(lr &Libraw_data_t) &Libraw_lensinfo_t

pub fn libraw_get_lensinfo(lr &Libraw_data_t) &Libraw_lensinfo_t {
	return C.libraw_get_lensinfo(lr)
}

fn C.libraw_get_imgother(lr &Libraw_data_t) &Libraw_imgother_t

pub fn libraw_get_imgother(lr &Libraw_data_t) &Libraw_imgother_t {
	return C.libraw_get_imgother(lr)
}

// helpers 
// dcraw emulation 
// information calls 
// memory writers 
// Additional calls for make_mem_image 
// free all internal data structures 
// Special value 0+1+2+3 
// Phase one correction/subtractBL calls 
// Returns libraw error code 
// Hotspots 
// Fujifilm compressed decoder public interface (to make parallel decoder) 
// CR3 decoder public interface to make parallel decoder 
// Panasonic Compression 8 parallel decoder stubs
// return: 0 if OK, non-zero on error
//void (LibRaw::*write_thumb)();
//void (LibRaw::*thumb_load_raw)();
// RawSpeed data 
// returns LIBRAW_SUCCESS on success 
// Fast cancel flag 
// DNG SDK data 
// X3F data 
// keep it even if USE_X3FTOOLS is not defined to do not change sizeof(LibRaw)
// __cplusplus 
// _LIBRAW_CLASS_H 


