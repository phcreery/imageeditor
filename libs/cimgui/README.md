## pub

Find:
`^(pub struct \w+ \{[\r\n]+)`
Repalce
`$1pub:\nmut:\n`

## To C Types

`pub struct ImGuiMultiSelectIO {}` to `pub struct C.ImGuiMultiSelectIO {} type ImGuiMultiSelectIO = C.ImGuiMultiSelectIO`

Find:
`^(pub struct )(\w+)( \{[\r\n]+(\n|.)*?\})`
Replace:
`$1C.$2$3\npub type $2 = C.$2`

&

&

Find:
`(?<!fn|pub|struct|type|\}|enum)([ |\(]&?)(Im\w*)`
Replace:
`$1C.$2`
