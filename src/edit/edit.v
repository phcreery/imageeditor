module edit

import processing
import common

interface Edit {
	name    string
	cs_from common.ColorspaceType
	cs_to   common.ColorspaceType
mut:
	enabled bool
	process(mut backend processing.Backend)
	draw() bool
}
