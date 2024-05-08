extern console: {
	log(...args)
}

class Greetings {
	private {
		_message: String = ''
	}

	constructor(@message) {
		this(message, 'Hello!')
	}

	constructor(@message, defaultMessage) {
		@message = if message.length != 0 set message else defaultMessage
	}

	greet(name) {
		return @message + '\nIt\'s nice to meet you, ' + name + '.'
	}
}

var dyn hello = Greetings.new('Hello world!')

console.log(hello.greet('miss White'))