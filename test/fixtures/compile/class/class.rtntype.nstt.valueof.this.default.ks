extern console

class Foobar {
	private {
		@value: String	= ''
	}
	value(): String => @value
	value(@value): valueof this
}

var f = Foobar.new()

console.log(`\(f.value('foobar').value())`)

export Foobar