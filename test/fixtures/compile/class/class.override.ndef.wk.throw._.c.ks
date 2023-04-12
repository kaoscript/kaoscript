abstract class Foobar {
	abstract foobar(x)
}

class Quxbaz extends Foobar {
	override foobar(x) ~ Error {
		throw Error.new()
	}
}