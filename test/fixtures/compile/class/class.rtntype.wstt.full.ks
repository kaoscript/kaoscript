extern console

class Foobar {
	private static {
		@instance: Foobar = Foobar.new()
	}
	static {
		instance(): valueof @instance
		instance(@instance)
	}
	private {
		@value: String	= ''
	}
	value(): valueof @value
	value(@value): valueof this
}

console.log(`\(Foobar.instance().value())`)

export Foobar