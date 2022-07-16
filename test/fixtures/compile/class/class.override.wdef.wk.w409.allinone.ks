func foobar(x: String): String => x
func quxbaz(x: Number): Number => x

class Foobar {
	foobar(x: Boolean) {
	}
	foobar(x: String, y: String = foobar(x)): String {
		return x
	}
}

class Quxbaz extends Foobar {
	override foobar(x, y) {
		return y
	}
	foobar(x: Number = quxbaz(42)) {
	}
}

export Foobar, Quxbaz