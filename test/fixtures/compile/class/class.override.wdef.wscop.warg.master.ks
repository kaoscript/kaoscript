func foobar(x): String => x

abstract class Foobar {
	abstract foobar(x: String, y: String = foobar(x)): String
}

export Foobar