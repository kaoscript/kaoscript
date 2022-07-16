class Foobar {
	foobar(x) => x * 1
	foobar(x: String) => x
}

class Quxbaz extends Foobar {
	override foobar(x) => x * 2
}