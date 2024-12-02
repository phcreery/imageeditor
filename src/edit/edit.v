module edit

import processing
import common
import time

interface Edit {
	name            string
	cs_from         common.ColorspaceType
	cs_to           common.ColorspaceType
	needed_backends []common.BackendID
mut:
	enabled      bool
	process_time time.Duration
	used_backend common.BackendID

	process(mut backend processing.Backend)
	draw() bool
}
