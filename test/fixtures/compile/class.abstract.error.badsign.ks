abstract class AbstractGreetings {
	private {
		_message: string = ''
	}
	
	constructor() {
		this('Hello!')
	}
	
	constructor(@message)
	
	abstract greet(name): String
}

class Greetings extends AbstractGreetings {
	greet(name: Number): String {
	}
}