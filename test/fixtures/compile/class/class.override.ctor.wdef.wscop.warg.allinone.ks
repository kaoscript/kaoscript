func foobar(x: String): String => x

class Foobar {
	constructor()
	constructor(x: String = '', y: String = foobar(x))
}

class Quxbaz extends Foobar {
	override constructor(x, y) {
		super()
	}
}

export Foobar, Quxbaz