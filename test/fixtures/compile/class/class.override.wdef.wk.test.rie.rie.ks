abstract class Foobar {
	abstract foobar(...args: Number)
}

class Quxbaz extends Foobar {
	override foobar(...args: Number) {
	}
}

export Foobar, Quxbaz