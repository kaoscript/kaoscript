extern console

class Foobar {
	private {
		@value: String	= ''
	}
}

impl Foobar {
	value(): @value
	value(@value): this
}

const f = new Foobar()

console.log(`\(f.value('foobar').value())`)

export Foobar