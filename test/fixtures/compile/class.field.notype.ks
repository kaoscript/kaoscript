extern console: {
	log(...args)
}

class Greetings {
	private {
		_message = ''
	}
	
	$create() {
		this('Hello!')
	}
	
	$create(message) {
		this._message = message
	}
	
	greet(name) {
		return this._message + '\nIt\'s nice to meet you, ' + name + '.'
	}
}

let hello = new Greetings('Hello world!')

console.log(hello.greet('miss White'))