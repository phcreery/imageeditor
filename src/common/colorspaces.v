module common


// insp from darktable/src/common/colorspaces.h
pub enum ColorspaceType {
	none
	raw
	lab
	rgb
	lch
	hsl
	// jzczhz
}

struct Color {
mut:
	r f32
	g f32
	b f32
}
