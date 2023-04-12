extern sealed class Error

class Exception extends Error {
	static {
		throw(message) ~ Exception {
			throw Exception.new(message)
		}
	}

	constructor(message) {
		super()

		this.message = message
	}
}

try {
	Exception.throw('foobar')
}