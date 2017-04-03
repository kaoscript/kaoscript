#![format(classes='es5', functions='es5')]

extern sealed class Error

class NotImplementedError extends Error {
	constructor(message = 'Not Implemented') {
		this.message = message
	}
}