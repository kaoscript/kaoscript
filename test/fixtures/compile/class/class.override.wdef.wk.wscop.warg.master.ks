func foobar(x: String): String => x

abstract class Foobar {
	abstract foobar(x: String, y: String = foobar(x)): String
}

export Foobar