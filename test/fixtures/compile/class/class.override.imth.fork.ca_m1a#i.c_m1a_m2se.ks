abstract class Foobar {
	abstract foobar(x): Number
}

class Quxbaz extends Foobar {
	foobar(x) => 1
	foobar(y: String) => 2
}