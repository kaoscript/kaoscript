abstract class Foobar {
	abstract foobar(...{0,3}args)
}

class Quxbaz extends Foobar {
	override foobar(args) {
	}
}

export Foobar, Quxbaz