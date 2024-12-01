module common

pub enum BackendID {
	none
	cpu
	cl
}

pub enum BackendStatus {
	ready
	notready
	busy
}
