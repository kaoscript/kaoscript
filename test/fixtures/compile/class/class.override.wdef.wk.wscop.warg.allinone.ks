func foobar(x: String): String => x

abstract class Foobar {
	abstract foobar(x: String, y: String = foobar(x)): String
}

class Quxbaz extends Foobar {
	override foobar(x, y) {
		return y
	}
}

export Foobar, Quxbaz