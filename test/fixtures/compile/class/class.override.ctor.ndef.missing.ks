extern console

class Foobar {
	constructor()
}

class Quxbaz extends Foobar {
	override constructor(x) {
		super()

		console.log(`\(x)`)
	}
}

export Foobar, Quxbaz