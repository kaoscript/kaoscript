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

var dyn hello = AbstractGreetings.new('Hello world!')