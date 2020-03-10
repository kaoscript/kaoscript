func foobar(x: String): String => x

class Foobar {
	constructor()
	constructor(x: String = '', y: String = foobar(x))
}

export Foobar