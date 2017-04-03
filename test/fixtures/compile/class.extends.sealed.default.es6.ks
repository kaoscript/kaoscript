extern sealed class Error

class NotImplementedError extends Error {
	constructor(message = 'Not Implemented') {
		this.message = message
	}
}