module edit

import imageio
import processing

interface Edit {
mut:
	enabled bool
	process(mut backend processing.Backend, img imageio.Image, mut new_img imageio.Image)
	draw() bool
}
