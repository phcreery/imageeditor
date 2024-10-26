module edit

import processing

interface Edit {
	name string
mut:
	enabled bool
	process(mut backend processing.Backend)
	draw() bool
}
