require|extern sealed class Foobar
require|extern system class Error

disclose Error {
	message: String
	name: String
	toString(): String
}

class FooError extends Error {
	override toString() => `FooError: \(@message)`
}

export Foobar, Error, FooError