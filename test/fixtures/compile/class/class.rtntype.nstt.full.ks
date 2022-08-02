extern console

class Foobar {
	private {
		@value: String	= ''
	}
	value(): @value
	value(@value): this
}

var f = new Foobar()

console.log(`\(f.value('foobar').value())`)

export Foobar