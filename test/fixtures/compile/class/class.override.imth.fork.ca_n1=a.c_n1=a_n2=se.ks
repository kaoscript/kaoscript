abstract class Foobar {
	abstract foobar(x)
}

class Quxbaz extends Foobar {
	foobar(x) => x * 1
	foobar(y: String) => y
}