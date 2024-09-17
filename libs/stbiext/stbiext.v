module stbiext

#flag -I @VEXEROOT/thirdparty/stb_image
#include "stb_image.h"

// #include "stb_image_write.h"
// #include "stb_image_resize2.h"
// #include "stb_v_header.h"
#flag @VEXEROOT/thirdparty/stb_image/stbi.o

// static unsigned char *convert_format(unsigned char *data, int img_n, int req_comp, uint x, uint y)
fn C.stbi__convert_format(data &u8, img_n int, req_comp int, x u32, y u32) &u8

pub fn convert_format(data &u8, img_n int, req_comp int, x u32, y u32) &u8 {
	return C.stbi__convert_format(data, img_n, req_comp, x, y)
}
