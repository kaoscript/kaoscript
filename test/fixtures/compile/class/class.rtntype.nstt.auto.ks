extern console

class Foobar {
	private {
		@value: String	= ''
	}
	value(): auto => @value
	value(@value): auto => this
}

var f = Foobar.new()

console.log(`\(f.value('foobar').value())`)

export Foobar