class Master {
	private {
		@value: String?		= null
	}
	value(): valueof @value
}

class Foobar extends Master {
	override value() => null
}