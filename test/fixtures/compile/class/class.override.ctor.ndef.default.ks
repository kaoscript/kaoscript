extern console

class Foobar {
	constructor()
	constructor(x: String)
}

class Quxbaz extends Foobar {
	override constructor(x) {
		super()

		console.log(`\(x)`)
	}
}

export Foobar, Quxbaz