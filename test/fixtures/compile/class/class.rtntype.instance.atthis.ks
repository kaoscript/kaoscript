extern console

class Foobar {
	private {
		@value: String	= ''
	}
	value(): @value
	value(@value): Foobar => this
}

const f = new Foobar()

console.log(`\(f.value('foobar').value())`)

export Foobar