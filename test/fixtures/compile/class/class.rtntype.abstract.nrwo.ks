extern console

abstract class Master {
	private {
		@value: String	= ''
	}
	abstract value(): String
	abstract value(value: String): Master
}

class Foobar extends Master {
	override value(): @value
	override value(@value): this
}

var f = Foobar.new()

console.log(`\(f.value('foobar').value())`)

export Master, Foobar