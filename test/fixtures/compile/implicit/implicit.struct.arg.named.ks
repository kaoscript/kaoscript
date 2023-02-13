enum FontWeight {
	Bold
	Normal
}

struct Style {
	fontWeight: FontWeight
}

var bold = new Style(fontWeight: .Bold)