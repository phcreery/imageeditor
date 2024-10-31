module main

import v.vmod

pub fn print_console_header(version string) {
	mod := vmod.decode(@VMOD_FILE) or { panic('Error decoding v.mod') }
	println("
 ███████████  █████ ██████████
░░███░░░░░███░░███ ░░███░░░░░█
 ░███    ░███ ░███  ░███  █ ░ 
 ░██████████  ░███  ░██████   
 ░███░░░░░░   ░███  ░███░░█   
 ░███         ░███  ░███ ░   █
 █████        █████ ██████████
░░░░░        ░░░░░ ░░░░░░░░░░ 
                              
PEYTON'S IMAGE EDITOR v${version}
")
}
