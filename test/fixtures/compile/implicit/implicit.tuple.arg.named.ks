enum FontWeight {
	Bold
	Normal
}

tuple Style {
	fontWeight: FontWeight
}

var bold = new Style(fontWeight: .Bold)