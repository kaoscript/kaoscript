extern sealed class Array

impl Array {
	pushUniq(...args) => this
}

class Foobar {
	values: Array	= []
}

var foobar = new Foobar()

foobar.values.pushUniq(42)