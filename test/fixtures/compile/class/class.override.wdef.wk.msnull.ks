abstract class Foobar {
	abstract foobar(x: Number, y: Number = 42)
}

class Quxbaz extends Foobar {
	override foobar(x: Number, y: Number)
	// foobar(x: Number, y: Number = 42)
}