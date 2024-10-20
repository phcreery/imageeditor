import os

fn using_wait_then_slurp(cmd string, args []string) {
	mut p := os.new_process(cmd)
	p.set_args(args)
	p.set_redirect_stdio()
	print('running process...')

	defer {
		p.close()
	}
	p.wait()

	print('stdout:')

	mut output := p.stdout_slurp()
	$if windows {
		output = output.replace('\r\r', '\r')
	}
	dump(output)
}

fn using_slurp_then_close(cmd string, args []string) {
	mut p := os.new_process(cmd)
	p.set_args(args)
	p.set_redirect_stdio()
	print('running process...')

	defer {
		p.close()
	}

	p.run()

	print('stdout:')

	mut output := p.stdout_slurp()

	// p.wait()
	p.close()

	$if windows {
		output = output.replace('\r\r', '\r')
	}
	dump(output)
}

fn using_exec(cmd string, args []string) {
	mut res := os.execute(cmd + ' ' + args.join(' '))
	dump(res.output)
}

fn main() {
	cmd := @VEXE

	// file := 'C:\\Users\\phcre\\Documents\\v\\imageeditor\\src\\main.v'
	file := os.norm_path(@VEXEROOT + '/vlib/os/process_windows.c.v') // doesn't work
	// file := os.norm_path(@VEXEROOT + '/vlib/os/const_nix.c.v') // works
	args := ['fmt', file]
	dump(cmd)
	dump(args)

	// using_wait_then_slurp(cmd, args)
	using_slurp_then_close(cmd, args)
	using_exec(cmd, args)
}
