class Messenger {
	private {
		_message: string = ''
	}

	constructor() {
		this('Hello!')
	}

	constructor(@message)

	message(@message) => this
	message() => @message
}

class Greetings extends Messenger {
	greet_01(name) {
		return `\(@message)\nIt's nice to meet you, \(name).`
	}

	greet_02(name) {
		return `\(@message())\nIt's nice to meet you, \(name).`
	}

	greet_03(name) {
		return `\(@message.toUpperCase())\nIt's nice to meet you, \(name).`
	}
}