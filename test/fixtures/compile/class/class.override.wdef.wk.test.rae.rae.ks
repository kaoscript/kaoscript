abstract class Foobar {
	abstract foobar(...args)
}

class Quxbaz extends Foobar {
	override foobar(...args) {
	}
}

export Foobar, Quxbaz