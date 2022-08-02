extern console

abstract class AbstractGreetings {
	private {
		_message: String = ''
	}

	constructor() {
		this('Hello!')
	}

	constructor(@message)

	abstract greet(name): String
}

class Greetings extends AbstractGreetings {
	private {
		_name: String
	}

	constructor(@name) {
		super()
	}

	greet(name = @name) => `\(@message) My name is \(name).`
}

var greetings = new Greetings('John')

console.log(`\(greetings.greet())`)
console.log(`\(greetings.greet('John'))`)