extern sealed class Error

class Exception extends Error {
	static {
		throw(message) ~ Exception {
			throw new Exception(message)
		}
	}
	
	constructor(message) {
		this.message = message
	}
}

try {
	Exception.throw('foobar')
}