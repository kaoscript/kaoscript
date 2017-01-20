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

let hello = new AbstractGreetings('Hello world!')