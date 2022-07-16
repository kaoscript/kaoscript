abstract class Foobar {
	abstract foobar(...{0,3}args)
}

class Quxbaz extends Foobar {
	override foobar(...{1,3}args) {
	}
}

export Foobar, Quxbaz