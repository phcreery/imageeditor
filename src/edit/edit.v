module edit

pub interface IImage {
	width  int
	height int
mut:
	data []u8
}

interface Edit {
	enabled bool
	process(img IImage) IImage
	draw() bool
}
