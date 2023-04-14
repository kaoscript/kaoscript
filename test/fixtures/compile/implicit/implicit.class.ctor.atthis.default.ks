enum FontWeight {
	Bold
	Normal
}

class Style {
	private {
		@weight: FontWeight
	}
	constructor(@weight = .Normal)
}