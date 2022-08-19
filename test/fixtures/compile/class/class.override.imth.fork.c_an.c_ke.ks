class Foobar {
	foobar(x?) {
	}
}

class Quxbaz extends Foobar {
	override foobar(x) {
	}
}

var x = new Quxbaz()

x.foobar(null)
x.foobar(0)