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
	greet(name) => `My name is \(name).`
}

class ProxyGreetings extends AbstractGreetings {
	private {
		_greeting: AbstractGreetings
	}
	constructor(@greeting)
	proxy {
		greet = @greeting.greet
	}
}

var greetings = ProxyGreetings.new(Greetings.new())

console.log(`\(greetings.greet('John'))`)