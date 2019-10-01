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

	greet(name, message = @message) => `\(message) My name is \(name).`
}

const greetings = new Greetings('John')

console.log(`\(greetings.greet('John'))`)
console.log(`\(greetings.greet('John', 'Hi!'))`)