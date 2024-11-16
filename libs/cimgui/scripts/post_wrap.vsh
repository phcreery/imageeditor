import os
import pcre

// 2024/11/16

// This script should executed after the wrapping process is done
// it will modify the generated file cimgui.v, fixing some things from c2v
fn fix_structs_to_pub(input string) string {
	// ## pub
	// Find:
	// `^(pub struct \w+ \{[\r\n]+)`
	// Repalce
	// `$1pub:\nmut:\n`

	// split the file into lines
	l := input.split('\n')
	mut lines := l.clone()
	r := pcre.new_regex(r'^(pub struct \w+ \{[\r\n]+)', 0) or { panic('could not compile regex') }
	for i in 0 .. lines.len {
		old_line := lines[i]
		m := r.match_str(old_line, 0, 0) or { continue }
		g1 := m.get(1) or { continue }

		new_line := g1 + 'pub:\nmut:\n'
		lines[i] = new_line
	}
	output := lines.join('\n')
	return output
}

fn fix_structs_to_typedef(input string) string {
	// ## To C Types and pub
	// `pub struct ImGuiMultiSelectIO {}` to
	// `@[typedef] \n pub struct C.ImGuiMultiSelectIO {} \n pub type ImGuiMultiSelectIO = C.ImGuiMultiSelectIO`
	//
	// Find:
	// `^(struct )(\w+)( \{[\r\n]+(\n|.)*?\})`
	// Replace:
	// `@[typedef]\npub $1C.$2$3\npub type $2 = C.$2`
	l := input.split('\n')
	mut lines := l.clone()
	r := pcre.new_regex(r'^(struct )(\w+)( \{[\r\n]+(\n|.)*?\})', 0) or {
		panic('could not compile regex')
	}
	for i in 0 .. lines.len {
		old_line := lines[i]
		m := r.match_str(old_line, 0, 0) or { continue }
		g1 := m.get(1) or { continue }
		g2 := m.get(2) or { continue }
		g3 := m.get(3) or { continue }

		new_line := '@[typedef]\npub ' + g1 + 'C.' + g2 + g3 + '\npub type ' + g2 + ' = C.' + g2
		lines[i] = new_line
	}
	output := lines.join('\n')
	return output
}

fn to_c_types(input string) string {
	// find all `pub struct C.Im* {...} \n type Im* = C.Im*`, store the name, and replace all references with C.Im*
	//
	// This works, but ot does enums too, so we need to exclude them from the search
	// Find:
	// `(?<!fn|pub|struct|type|\}|enum)([ |\(]&?)(Im\w*)`
	// Replace:
	// `$1C.$2`

	// split the file into lines
	l := input.split('\n')
	mut lines := l.clone()

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
	output := lines.join('\n')
	return output
}

// TODO: [inline]

// Open the file

// file := os.real_path(@VMODROOT + '/libs/cimgui/cimgui.v.old')
file := os.real_path(@VMODROOT + '/thirdparty/cimgui/cimgui.v')

// dump(file)
mut cimguiv := os.read_file(file) or { panic('could not read file') }

cimguiv = fix_structs_to_pub(cimguiv)
cimguiv = fix_structs_to_typedef(cimguiv)
cimguiv = to_c_types(cimguiv)

file2 := os.real_path(@VMODROOT + '/libs/cimgui/cimgui.post.v')
os.write_file(file2, cimguiv) or { panic('could not write file') }
