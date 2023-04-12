enum FontWeight {
	Bold
	Normal
}

struct Style {
	fontWeight: FontWeight
}

var bold = Style.new(fontWeight: .Bold)