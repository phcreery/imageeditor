module edit

import imageio
import processing

interface Edit {
	name string
mut:
	enabled bool
	process(mut backend processing.Backend, img imageio.Image, mut new_img imageio.Image)
	draw() bool
}
