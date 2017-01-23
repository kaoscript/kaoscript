class Greetings {
	private {
		_message: String = 'Hello!'
	}
	
	constructor()
	
	constructor(message: String) {
		@message = message
	}
	
	constructor(number: Number) {
		this(`\(number)`)
	}
}