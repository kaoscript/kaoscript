extern console

class Foobar {
	private {
		@value: String	= ''
	}
	value(): auto => @value
	value(@value): auto => this
}

const f = new Foobar()

console.log(`\(f.value('foobar').value())`)

export Foobar