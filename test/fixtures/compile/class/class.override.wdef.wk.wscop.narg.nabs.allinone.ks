func foobar(): String => ''

class Foobar {
	foobar(x: String = foobar()): String {
		return x
	}
}

class Quxbaz extends Foobar {
	override foobar(x) {
		return x
	}
}

export Foobar, Quxbaz