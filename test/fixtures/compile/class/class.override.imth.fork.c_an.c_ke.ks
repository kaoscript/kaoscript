class Foobar {
	foobar(x?) {
	}
}

class Quxbaz extends Foobar {
	override foobar(x) {
	}
}

var x = Quxbaz.new()

x.foobar(null)
x.foobar(0)