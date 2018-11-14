#![format(classes='es5', functions='es5')]

extern sealed class Error

class Exception extends Error {
	public {
		fileName: String		= null
		lineNumber: Number		= 0
		message: String
		name: String
	}
	constructor(@message) {
		super()
		
		@name = this.constructor.name
	}
	constructor(@message, @fileName, @lineNumber) {
		this(message)
	}
}