extern console

class Foobar {
	private {
		@value: String	= ''
	}
	value(): String => @value
	value(@value): typeof this {
		return 0
	}
}

var f = Foobar.new()

console.log(`\(f.value('foobar').value())`)

export Foobar