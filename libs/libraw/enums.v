module libraw

// pub enum OpenFlags as u32 {
// 	bigfile = C.LIBRAW_OPEN_BIGFILE
// 	file = C.LIBRAW_OPEN_FILE
// }
pub enum ConstructorFlags as u32 {
	none_               = C.LIBRAW_OPTIONS_NONE
	no_dataerr_callback = C.LIBRAW_OPTIONS_NO_DATAERR_CALLBACK
}

pub enum LibRawErrors {
	success                           = C.LIBRAW_SUCCESS
	unspecified_error                 = C.LIBRAW_UNSPECIFIED_ERROR
	file_unsupported                  = C.LIBRAW_FILE_UNSUPPORTED
	request_for_nonexistent_image     = C.LIBRAW_REQUEST_FOR_NONEXISTENT_IMAGE
	out_of_order_call                 = C.LIBRAW_OUT_OF_ORDER_CALL
	no_thumbnail                      = C.LIBRAW_NO_THUMBNAIL
	unsupported_thumbnail             = C.LIBRAW_UNSUPPORTED_THUMBNAIL
	input_closed                      = C.LIBRAW_INPUT_CLOSED
	not_implemented                   = C.LIBRAW_NOT_IMPLEMENTED
	request_for_nonexistent_thumbnail = C.LIBRAW_REQUEST_FOR_NONEXISTENT_THUMBNAIL
	unsufficient_memory               = C.LIBRAW_UNSUFFICIENT_MEMORY
	data_error                        = C.LIBRAW_DATA_ERROR
	io_error                          = C.LIBRAW_IO_ERROR
	cancelled_by_callback             = C.LIBRAW_CANCELLED_BY_CALLBACK
	bad_crop                          = C.LIBRAW_BAD_CROP
	too_big                           = C.LIBRAW_TOO_BIG
	mempool_overflow                  = C.LIBRAW_MEMPOOL_OVERFLOW
}

pub enum LibRawImageFormats {
	jpeg   = C.LIBRAW_IMAGE_JPEG
	bitmap = C.LIBRAW_IMAGE_BITMAP
}
