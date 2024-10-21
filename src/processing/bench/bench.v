module bench

import time

pub struct Benchmark {
pub:
	name string
pub mut:
	sw time.StopWatch
}

pub fn Benchmark.new(name string) Benchmark {
	return Benchmark{
		name: name
		sw:   time.new_stopwatch()
	}
}

pub fn (mut b Benchmark) elapsed() f64 {
	return f64(b.sw.elapsed().microseconds()) / 1000.0
}

pub fn (mut b Benchmark) restart() {
	b.sw.restart()
}

pub fn (mut b Benchmark) print_elapsed() {
	eprintln('${b.name}: ${b.elapsed()}ms')
}

pub fn (mut b Benchmark) print_elapsed_and_restart() {
	b.print_elapsed()
	b.restart()
}

pub fn (mut b Benchmark) print_elapsed_and_restart_with_message(msg string) {
	eprintln('${b.name}: ${b.elapsed()}ms | ${msg}')
	b.restart()
}

pub fn (mut b Benchmark) finish() {
	b.print_elapsed()
}
