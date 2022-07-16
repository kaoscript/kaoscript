extern sealed class Error

class NotImplementedError extends Error {
	constructor(message = 'Not Implemented') {
		super()
		
		this.message = message
	}
}