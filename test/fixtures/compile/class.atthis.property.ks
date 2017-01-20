class Greetings {
	private {
		_message: string = ''
	}
	
	constructor() {
		this('Hello!')
	}
	
	constructor(@message)
	
	message(@message) => this
	message() => @message
	
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