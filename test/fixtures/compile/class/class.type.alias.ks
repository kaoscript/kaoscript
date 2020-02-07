extern console: {
	log(...args)
}

type float = Number

class Person {
	private {
		_height: float	= 0
	}

	constructor()
	height(): float => this._height
	height(@height) => this
}