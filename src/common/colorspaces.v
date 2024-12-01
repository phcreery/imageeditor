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

// RGB values in the range [0, 255] (u8).
pub struct RGBu8 {
pub mut:
	r u8
	g u8
	b u8
}

pub struct RGBAu8 {
pub mut:
	r u8
	g u8
	b u8
	a u8
}

// RGB values in the range [0, 1] (f64).
pub struct RGB {
pub mut:
	r f64
	g f64
	b f64
}

pub struct RGBA {
pub mut:
	r f64
	g f64
	b f64
	a f64
}

pub struct HSV {
pub mut:
	h f64
	s f64
	v f64
}

pub struct HSL {
pub mut:
	h f64
	s f64
	l f64
}