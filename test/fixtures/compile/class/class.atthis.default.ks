extern console: {
	log(...args)
}

class Greetings {
	private {
		_message: string = ''
	}

	constructor() {
		this('Hello!')
	}

	constructor(@message)

	greet(name) {
		return @message + '\nIt\'s nice to meet you, ' + name + '.'
	}
}

var dyn hello = Greetings.new('Hello world!')

console.log(hello.greet('miss White'))