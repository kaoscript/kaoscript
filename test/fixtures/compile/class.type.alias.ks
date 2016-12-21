extern console: {
	log(...args)
}

type float = Number

class Person {
	private {
		_height: float
	}
	
	$create()
	height(): float => this._float
	height(@height: float) => this
}