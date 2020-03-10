abstract class Foobar {
	abstract foobar(x: String = ''): String
}

class Quxbaz extends Foobar {
	override foobar(x) {
		return x
	}
}

export Foobar, Quxbaz