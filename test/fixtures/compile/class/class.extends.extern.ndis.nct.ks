extern system class Error {
	message: String
	name: String
	toString(): String
}

class FooError extends Error {
	override toString() => `FooError: \(@message)`
}

export Error, FooError