class Foobar {
	private late {
		@value		= null
	}
	value(): valueof @value
}

func foovar(x: Foobar) {
	if var value ?= x.value() {
		value.print()
	}
}