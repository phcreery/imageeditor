module edit

import processing
import common
import processing.cl

interface Edit {
	name    string
	cs_from common.ColorspaceType
	cs_to   common.ColorspaceType
mut:
	enabled bool

	process(mut backend processing.Backend)

	// process(mut backend cl.BackendCL)
	draw() bool
}
