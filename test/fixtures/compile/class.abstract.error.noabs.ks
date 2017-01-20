class Greetings {
	private {
		_message: string = ''
	}
	
	constructor() {
		this('Hello!')
	}
	
	constructor(@message)
	
	abstract greet(name): String
}