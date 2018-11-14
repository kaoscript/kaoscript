class Greetings {
	private {
		__message: String = ''
	}
	
	constructor() {
		this('Hello!')
	}
	
	constructor(@message())
	
	message(message: String) {
		this.__message = message
		
		return this
	}
	
	message() => this.__message
}