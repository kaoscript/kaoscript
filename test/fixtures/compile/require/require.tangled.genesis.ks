require|extern sealed class Foobar
require|extern sealed class Error

disclose Error {
	message: String
	name: String
	toString(): String
}

class FooError extends Error {
	override toString() => `FooError: \(@message)`
}

export Foobar, Error, FooError