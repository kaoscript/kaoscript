extern systemic class Error {
	message: String
	name: String
	toString(): String
}

class FooError extends Error {
	constructor() {
		super()
	}
	override toString() => `FooError: \(@message)`
}

export Error, FooError