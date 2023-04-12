extern sealed class Array

impl Array {
	pushUniq(...args) => this
}

class Foobar {
	values: Array	= []
}

var foobar = Foobar.new()

foobar.values.pushUniq(42)