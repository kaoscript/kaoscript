enum FontWeight {
	Bold
	Normal
}

class Style {
	foobar(bold: Boolean) {
		@quxbaz(bold ? .Bold : null)
	}
	quxbaz(weight: FontWeight?) {
	}
}