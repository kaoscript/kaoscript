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

var f = Foobar.new()

console.log(`\(f.value('foobar').value())`)

export Foobar