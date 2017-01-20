class Greetings {
	private {
		_message: string = ''
	}
	
	constructor() {
		this('Hello!')
	}
	
	constructor(message?) {
		this._message = message
	}
	
	destructor() {
		this._message = null
	}
	
	greet(name) {
		return `\(this._message)\nIt's nice to meet you, \(name).`
	}
}