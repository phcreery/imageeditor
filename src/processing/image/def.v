module image

pub struct Image {
pub:
	width       int
	height      int
	nr_channels int
pub mut:
	data []u8
}
