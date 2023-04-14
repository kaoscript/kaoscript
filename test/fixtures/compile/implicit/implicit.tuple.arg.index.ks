enum FontWeight {
	Bold
	Normal
}

tuple Style [
	fontWeight: FontWeight
]

var bold = Style.new(.Bold)