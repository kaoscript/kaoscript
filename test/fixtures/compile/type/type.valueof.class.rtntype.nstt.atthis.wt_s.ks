extern console

class Foobar {
	private {
		@value: String	= ''
	}
	value(): valueof @value
	value(@value): Foobar => this
}

var f = Foobar.new()

console.log(`\(f.value('foobar').value())`)

export Foobar