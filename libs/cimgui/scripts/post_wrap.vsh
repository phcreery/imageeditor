// import regex
import os
import pcre

// This script should executed after the wrapping process is done
// it will modify the generated file cimgui.v, fixing some things from c2v
fn to_pub() {
	// ## pub
	// Find:
	// `^(pub struct \w+ \{[\r\n]+)`
	// Repalce
	// `$1pub:\nmut:\n`
}

fn to_c_types() {
	// ## To C Types and pub

	// `pub struct ImGuiMultiSelectIO {}` to
	// `pub struct C.ImGuiMultiSelectIO {} \n pub type ImGuiMultiSelectIO = C.ImGuiMultiSelectIO`
	//
	// Find:
	// `^(struct )(\w+)( \{[\r\n]+(\n|.)*?\})`
	// Replace:
	// `pub $1C.$2$3\npub type $2 = C.$2`
	//
	// &
	//
	// &
	// This works, but ot does enums too, so we need to exclude them
	// Find:
	// `(?<!fn|pub|struct|type|\}|enum)([ |\(]&?)(Im\w*)`
	// Replace:
	// `$1C.$2`
}

// TODO: [inline]

// Open the file
file := os.real_path(@VMODROOT + '/libs/cimgui/cimgui.v.old')
file2 := os.real_path(@VMODROOT + '/libs/cimgui/cimgui.post.v')
dump(file)
cimguiv := os.read_file(file) or { panic('could not read file') }

// split the file into lines
l := cimguiv.split('\n')

mut lines := l.clone()

// find all `pub struct C.Im* {...} \n type Im* = C.Im*`, store the name, and replace all references with C.Im*
mut names := []string{}
r := pcre.new_regex(r'^pub struct C.(\w+)', 0) or { panic('could not compile regex') }
for line in lines {
	m := r.match_str(line, 0, 0) or { continue }
	name := m.get(1) or { continue }
	dump(name)
	names << name
}
dump(names)
r2 := pcre.new_regex(r'(.*?)(?<!pub struct|pub type|\}|pub enum|C\.|_)([\& ])(Im\w*)',
	0) or { panic('could not compile regex') }
for i in 0 .. lines.len {
	old_line := lines[i]
	ms := r2.match_str_many(old_line, 0, 0) or { continue }

	mut sections := []string{}
	mut remaining_section := ''

	// dump(ms)
	println('')
	dump(old_line)
	for m in ms {
		// dump(m)
		g1 := m.get(1) or { continue }
		g2 := m.get(2) or { continue }
		g3 := m.get(3) or { continue }

		// dump(g1)
		// dump(g2)
		// dump(g3)
		// replace
		if g3 in names {
			new_section := g1 + g2 + 'C.' + g3
			sections << new_section
		} else {
			sections << g1 + g2 + g3
		}
		remaining_section = old_line.substr(m.ovector[1], old_line.len)
	}

	mut new_line := ''

	for section in sections {
		new_line += section
	}
	new_line += remaining_section
	dump(new_line)
	lines[i] = new_line
}

// join the lines and write the file
cimguiv2 := lines.join('\n')
os.write_file(file2, cimguiv2) or { panic('could not write file') }
