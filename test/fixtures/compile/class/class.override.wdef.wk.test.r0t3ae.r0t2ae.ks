abstract class Foobar {
	abstract foobar(...{0,3}args)
}

class Quxbaz extends Foobar {
	override foobar(...{0,2}args) {
	}
}

export Foobar, Quxbaz