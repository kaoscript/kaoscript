class Greetings {
	private {
		_message: String = 'Hello!'
	}
	
	constructor()
	
	constructor(@message)
	
	constructor(number: Number) {
		this(`\(number)`)
	}
}