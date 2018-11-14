class Greetings {
	private {
		_message: String = 'Hello!'
	}
	
	constructor()
	
	constructor(message) {
		@message = message
	}
	
	constructor(number: Number) {
		this(`\(number)`)
	}
}