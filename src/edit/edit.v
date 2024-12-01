module edit

import processing
import common

interface Edit {
	name            string
	cs_from         common.ColorspaceType
	cs_to           common.ColorspaceType
	needed_backends []common.BackendID
mut:
	enabled bool

	process(mut backend processing.Backend)
	draw() bool
}
