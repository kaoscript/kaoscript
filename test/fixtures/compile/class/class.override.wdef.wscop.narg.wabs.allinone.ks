func foobar(): String => ''

abstract class Foobar {
	abstract foobar(x: String = foobar()): String
}

class Quxbaz extends Foobar {
	override foobar(x) {
		return x
	}
}

export Foobar, Quxbaz