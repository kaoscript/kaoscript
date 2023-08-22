extern console

class Foobar {
	private {
		@value: String	= ''
	}
}

impl Foobar {
	value(): valueof @value
	value(@value): valueof this
}

var f = Foobar.new()

console.log(`\(f.value('foobar').value())`)

export Foobar