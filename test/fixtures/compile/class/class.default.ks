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
	
	constructor(message) {
		this._message = message
	}
	
	greet(name) {
		return this._message + '\nIt\'s nice to meet you, ' + name + '.'
	}
}

var dyn hello = new Greetings('Hello world!')

console.log(hello.greet('miss White'))