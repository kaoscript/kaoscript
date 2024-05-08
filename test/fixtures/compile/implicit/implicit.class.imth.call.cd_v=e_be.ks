enum FontWeight {
	Bold
	Normal
}

class Style {
	foobar(bold: Boolean) {
		@quxbaz(if bold set .Bold else null)
	}
	quxbaz(weight: FontWeight?) {
	}
}