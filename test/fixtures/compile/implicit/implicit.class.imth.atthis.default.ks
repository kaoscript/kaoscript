enum FontWeight {
	Bold
	Normal
}

class Style {
	private {
		@weight: FontWeight = .Normal
	}
	foobar(@weight = .Normal) {
	}
}