extern console: {
	log(...args)
}

class Greetings {
	private {
		_message: String
	}

	constructor(@message = 'Hello!')

	greet(name) {
		return @message + '\nIt\'s nice to meet you, ' + name + '.'
	}
}

let hello = new Greetings('Hello world!')

console.log(hello.greet('miss White'))