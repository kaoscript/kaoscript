abstract class Foobar {
	abstract foobar(x)
}

class Quxbaz extends Foobar {
	foobar(x) => 1
	foobar(x: String) => 2
}