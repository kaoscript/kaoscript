class Foobar {
	constructor()
	constructor(x: String = '')
}

class Quxbaz extends Foobar {
	override constructor(x) {
		super()
	}
}

export Foobar, Quxbaz