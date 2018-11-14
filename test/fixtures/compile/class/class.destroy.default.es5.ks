#![format(classes='es5', functions='es5')]

class Greetings {
	private {
		_message: string = ''
	}
	
	constructor() {
		this('Hello!')
	}
	
	constructor(@message)
	
	destructor() {
		this._message = null
	}
	
	greet(name) {
		return `\(this._message)\nIt's nice to meet you, \(name).`
	}
}