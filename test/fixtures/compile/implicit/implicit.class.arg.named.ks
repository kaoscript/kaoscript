enum FontWeight {
	Bold
	Normal
}

class Style {
	private {
		@fontWeight: FontWeight
	}
	constructor(@fontWeight)
}

var bold = Style.new(fontWeight: .Bold)