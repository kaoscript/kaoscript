extern sealed class Error

class Exception extends Error {
	public {
		message: String
		name: String
	}
	constructor(@message) {
		@name = this.constructor.name
	}
}