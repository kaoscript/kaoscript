extern console

abstract class Master {
	private {
		@value: String	= ''
	}
	abstract value(): @value
	abstract value(@value): this
}

class Foobar extends Master {
	value(): @value
	value(@value) => this
}

var f = Foobar.new()

console.log(`\(f.value('foobar').value())`)

export Master, Foobar