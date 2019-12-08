extern console

class Foobar {
	private static {
		@instance: Foobar = new Foobar()
	}
	static {
		instance(): @instance
		instance(@instance)
	}
	private {
		@value: String	= ''
	}
	value(): @value
	value(@value): this
}

console.log(`\(Foobar.instance().value())`)

export Foobar