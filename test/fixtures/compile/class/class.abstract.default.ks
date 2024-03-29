extern console: {
	log(...args)
}

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
	greet(name) => `\(@message)\nIt's nice to meet you, \(name).`
}

var hello = Greetings.new('Hello world!')

console.log(`\(hello.greet('miss White'))`)

export AbstractGreetings, Greetings