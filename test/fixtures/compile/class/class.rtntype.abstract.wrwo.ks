extern console

abstract class Master {
	private {
		@value: String	= ''
	}
	abstract value(): typeof @value
	abstract value(@value): typeof this
}

class Foobar extends Master {
	override value(): valueof @value
	override value(@value): valueof this
}

var f = Foobar.new()

console.log(`\(f.value('foobar').value())`)

export Master, Foobar